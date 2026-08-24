import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @Query private var habits: [Habit]
    @Query private var tags: [Tag]

    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingTemplates = false
    @State private var exportURL: URL?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importReplace = true
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                Section("Notifications") {
                    LabeledContent("Permission", value: statusLabel)
                    Button("Request permission") {
                        Task {
                            _ = await ReminderScheduler.requestAuthorizationIfNeeded()
                            authStatus = await ReminderScheduler.authorizationStatus()
                        }
                    }
                }

                Section("Habits") {
                    Button("Browse templates") { showingTemplates = true }
                }

                Section("Backup (local file / AirDrop)") {
                    Toggle("Replace all on import", isOn: $importReplace)
                    Button("Export JSON") { exportData() }
                    Button("Import JSON") { showingImporter = true }
                }

                Section("Privacy") {
                    Label("Fully offline — no internet, accounts, or cloud sync", systemImage: "lock.shield")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    LabeledContent("Version", value: "2.0")
                    LabeledContent("App", value: "Habit Tracker")
                }

                Section {
                    Button("Reset onboarding") { hasCompletedOnboarding = false }
                }
            }
            .navigationTitle("Settings")
            .task { authStatus = await ReminderScheduler.authorizationStatus() }
            .sheet(isPresented: $showingTemplates) {
                OnboardingView(isEmbedded: true) { showingTemplates = false }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: exportURL.map { FileDataDocument(url: $0) },
                contentType: .json,
                defaultFilename: "habit-tracker-backup"
            ) { _ in }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert("Backup", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private var statusLabel: String {
        switch authStatus {
        case .authorized, .provisional, .ephemeral: return "Allowed"
        case .denied: return "Denied"
        case .notDetermined: return "Not asked"
        @unknown default: return "Unknown"
        }
    }

    private func exportData() {
        do {
            let data = try DataExportImport.exportJSON(habits: habits, tags: tags)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("habit-tracker-backup.json")
            try data.write(to: url, options: .atomic)
            exportURL = url
            showingExporter = true
        } catch {
            alertMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            alertMessage = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                alertMessage = "Could not access file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                try DataExportImport.importJSON(data, into: modelContext, replace: importReplace)
                for habit in try modelContext.fetch(FetchDescriptor<Habit>()) where habit.reminderEnabled {
                    Task { await ReminderScheduler.sync(habit: habit) }
                }
                WidgetBridge.reload()
                alertMessage = "Import finished."
            } catch {
                alertMessage = "Import failed: \(error.localizedDescription)"
            }
        }
    }
}

struct FileDataDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(url: URL) {
        data = (try? Data(contentsOf: url)) ?? Data()
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
