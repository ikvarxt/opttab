import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
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

                Picker("Letter order", selection: $settings.keyOrder) {
                    ForEach(KeyOrder.allCases) { order in
                        Text(order.label).tag(order)
                    }
                }
            }

            settingsSection {
                Toggle("Show app names", isOn: $settings.showAppNames)
                Toggle("Close bar after switching", isOn: $settings.closeAfterSelection)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(settings.appSource.detail)
                Text(settings.keyOrder.detail)
                Text("Changes apply immediately.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 460)
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
}
