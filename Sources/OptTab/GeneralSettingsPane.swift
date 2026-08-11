import SwiftUI

struct GeneralSettingsPane: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        Form {
            Section {
                TriggerSummaryCard(settings: settings)
            }

            Section("Trigger") {
                SettingsRow(
                    symbol: "option",
                    tint: .blue,
                    title: "Hold key"
                ) {
                    Picker("Hold key", selection: $settings.triggerKey) {
                        ForEach(TriggerKey.allCases) { key in
                            Text(verbatim: "\(key.glyph)   \(key.label)").tag(key)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }

                SettingsRow(
                    symbol: "f.square",
                    tint: .indigo,
                    title: "Secondary trigger",
                    detail: "For programmable keyboards that cannot send a real Globe or modifier event."
                ) {
                    Picker("Secondary trigger", selection: $settings.secondaryTriggerKey) {
                        ForEach(SecondaryTriggerKey.allCases) { key in
                            Text(key.label).tag(key)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }

            Section("Apps") {
                SettingsRow(
                    symbol: "square.grid.2x2.fill",
                    tint: .teal,
                    title: "App source",
                    detail: settings.appSource.detail
                ) {
                    Picker("App source", selection: $settings.appSource) {
                        ForEach(AppSource.allCases) { source in
                            Text(source.label).tag(source)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }

                SettingsRow(
                    symbol: "macwindow.on.rectangle",
                    tint: .purple,
                    title: "Window behavior",
                    detail: settings.windowActivationBehavior.detail
                ) {
                    Picker("Window behavior", selection: $settings.windowActivationBehavior) {
                        ForEach(WindowActivationBehavior.allCases) { behavior in
                            Text(behavior.label).tag(behavior)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }

            Section("Letters") {
                SettingsRow(
                    symbol: "keyboard.fill",
                    tint: .cyan,
                    title: "Keyboard layout",
                    detail: settings.keyboardLayout.detail
                ) {
                    Picker("Keyboard layout", selection: $settings.keyboardLayout) {
                        ForEach(KeyboardLayout.allCases) { layout in
                            Text(layout.label).tag(layout)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }

                SettingsRow(
                    symbol: "textformat.abc",
                    tint: .mint,
                    title: "Letter order",
                    detail: settings.keyOrder.detail
                ) {
                    Picker("Letter order", selection: $settings.keyOrder) {
                        ForEach(KeyOrder.allCases) { order in
                            Text(order.label).tag(order)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }

            Section("Startup") {
                SettingsRow(
                    symbol: "power",
                    tint: .green,
                    title: "Launch at login",
                    detail: settings.launchAtLoginStatus
                ) {
                    Toggle("Launch at login", isOn: launchAtLoginBinding)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }

                if let launchAtLoginError = settings.launchAtLoginError {
                    Label(launchAtLoginError, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
        }
        .formStyle(.grouped)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { settings.launchAtLogin },
            set: { settings.setLaunchAtLogin($0) }
        )
    }
}

private struct TriggerSummaryCard: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 7) {
                KeyCapView(text: settings.triggerKey.glyph)

                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                KeyCapView(text: "F")
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Hold \(settings.triggerKey.label), then press the letter on an app")
                    .font(.callout.weight(.medium))

                Text(secondaryLine)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private var secondaryLine: String {
        guard settings.secondaryTriggerKey != .none else {
            return "Release the key to close the bar."
        }

        return "\(settings.secondaryTriggerKey.label) works as a second trigger."
    }
}
