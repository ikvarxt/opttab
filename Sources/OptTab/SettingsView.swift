import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                Divider()

                settingsSection {
                    Picker("Hold key", selection: $settings.triggerKey) {
                        ForEach(TriggerKey.allCases) { key in
                            Text(key.label).tag(key)
                        }
                    }

                    Picker("App source", selection: $settings.appSource) {
                        ForEach(AppSource.allCases) { source in
                            Text(source.label).tag(source)
                        }
                    }

                    Picker("Window behavior", selection: $settings.windowActivationBehavior) {
                        ForEach(WindowActivationBehavior.allCases) { behavior in
                            Text(behavior.label).tag(behavior)
                        }
                    }

                    Picker("Keyboard layout", selection: $settings.keyboardLayout) {
                        ForEach(KeyboardLayout.allCases) { layout in
                            Text(layout.label).tag(layout)
                        }
                    }

                    Picker("Letter order", selection: $settings.keyOrder) {
                        ForEach(KeyOrder.allCases) { order in
                            Text(order.label).tag(order)
                        }
                    }
                }

                settingsSection {
                    Toggle("Launch at login", isOn: launchAtLoginBinding)
                    Toggle("Show app names", isOn: $settings.showAppNames)
                    Toggle("Close bar after switching", isOn: $settings.closeAfterSelection)
                }

                fixedAppShortcutsSection

                VStack(alignment: .leading, spacing: 8) {
                    Text(settings.launchAtLoginStatus)
                    if let launchAtLoginError = settings.launchAtLoginError {
                        Text("Launch at login error: \(launchAtLoginError)")
                    }
                    Text(settings.appSource.detail)
                    Text(settings.windowActivationBehavior.detail)
                    Text(settings.keyboardLayout.detail)
                    Text(settings.keyOrder.detail)
                    Text("Fixed app keys take priority; dynamic apps skip keys reserved here.")
                    Text("Changes apply immediately.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .frame(width: 540, height: 620)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("OptTab Settings")
                .font(.title2.weight(.semibold))

            Text("Hold \(settings.triggerKey.label), then press the shown letter to switch apps.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func settingsSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { settings.launchAtLogin },
            set: { settings.setLaunchAtLogin($0) }
        )
    }

    private var fixedAppShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fixed App Keys")
                    .font(.headline)

                Spacer()

                Button("Add App...") {
                    addFixedAppShortcut()
                }
                .disabled(!settings.canAddFixedAppShortcut)
            }

            if settings.fixedAppShortcuts.isEmpty {
                Text("No fixed app keys yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(settings.fixedAppShortcuts) { shortcut in
                        FixedAppShortcutRow(
                            shortcut: shortcut,
                            keyLabel: keyLabelBinding(for: shortcut),
                            remove: {
                                settings.removeFixedAppShortcut(id: shortcut.id)
                            }
                        )
                    }
                }
            }

            Text("If two apps use the same key, changing one swaps the assignments.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func keyLabelBinding(for shortcut: FixedAppShortcut) -> Binding<String> {
        Binding(
            get: {
                settings.fixedAppShortcuts
                    .first(where: { $0.id == shortcut.id })?
                    .keyLabel ?? shortcut.keyLabel
            },
            set: { keyLabel in
                settings.updateFixedAppShortcut(id: shortcut.id, keyLabel: keyLabel)
            }
        )
    }

    private func addFixedAppShortcut() {
        let panel = NSOpenPanel()
        panel.title = "Choose an app"
        panel.prompt = "Add"
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.applicationBundle]

        guard panel.runModal() == .OK, let appURL = panel.url else {
            return
        }

        settings.addFixedAppShortcut(appURL: appURL)
    }
}

private struct FixedAppShortcutRow: View {
    let shortcut: FixedAppShortcut
    @Binding var keyLabel: String
    let remove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.appName)
                    .lineLimit(1)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Picker("Key", selection: $keyLabel) {
                ForEach(KeyBinding.availableLabels, id: \.self) { label in
                    Text(label).tag(label)
                }
            }
            .labelsHidden()
            .frame(width: 74)

            Button("Remove", action: remove)
        }
    }

    private var icon: NSImage {
        let image = NSWorkspace.shared.icon(forFile: shortcut.appPath)
        image.size = NSSize(width: 32, height: 32)
        return image
    }

    private var statusText: String {
        if FileManager.default.fileExists(atPath: shortcut.appPath) {
            return shortcut.appPath
        }

        return "App not found at saved path"
    }
}
