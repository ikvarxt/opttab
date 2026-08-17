import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FixedAppsSettingsPane: View {
    @ObservedObject var settings: AppSettings

    @StateObject private var recorder = KeyRecorder()
    @State private var swap: FixedAppKeySwap?

    var body: some View {
        Form {
            Section {
                if settings.fixedAppShortcuts.isEmpty {
                    emptyState
                } else {
                    ForEach(settings.fixedAppShortcuts) { shortcut in
                        FixedAppShortcutRow(
                            shortcut: shortcut,
                            keyLabel: keyLabelBinding(for: shortcut),
                            layout: settings.keyboardLayout,
                            recorder: recorder,
                            remove: { settings.removeFixedAppShortcut(id: shortcut.id) }
                        )
                    }
                }
            } header: {
                HStack(spacing: SettingsMetrics.gap) {
                    Text("Reserved keys")

                    Spacer(minLength: 0)

                    Button {
                        addFixedAppShortcut()
                    } label: {
                        Label("Add App…", systemImage: "plus")
                    }
                    .disabled(!settings.canAddFixedAppShortcut)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("A fixed key always opens the same app, even when it is not in the Dock or running.")
                    Text("Click a key cap, then press the letter you want. Esc cancels.")
                    Text("Fixed keys win over the dynamic list, and taking a letter that is already used swaps the two apps.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .overlay(alignment: .bottom) {
            if let swap {
                KeySwapToast(swap: swap)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: swap)
        .task(id: swap) {
            guard swap != nil else { return }

            try? await Task.sleep(nanoseconds: 3_200_000_000)
            swap = nil
        }
    }

    private var emptyState: some View {
        HStack(spacing: SettingsMetrics.gap) {
            SettingsIconBadge(symbol: "pin", tint: .orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("No fixed keys yet")

                Text("Pin an app to a letter that never changes, even when the app is closed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }

    private func keyLabelBinding(for shortcut: FixedAppShortcut) -> Binding<String> {
        Binding(
            get: {
                settings.fixedAppShortcuts
                    .first(where: { $0.id == shortcut.id })?
                    .keyLabel ?? shortcut.keyLabel
            },
            set: { keyLabel in
                swap = settings.updateFixedAppShortcut(id: shortcut.id, keyLabel: keyLabel)
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
    let layout: KeyboardLayout
    @ObservedObject var recorder: KeyRecorder
    let remove: () -> Void

    @State private var isHoveringRemove = false

    var body: some View {
        HStack(spacing: SettingsMetrics.gap) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 1) {
                Text(shortcut.appName)
                    .lineLimit(1)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(isMissing ? AnyShapeStyle(.orange) : AnyShapeStyle(.secondary))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: SettingsMetrics.gap)

            KeyCaptureButton(
                keyLabel: keyLabel,
                appName: shortcut.appName,
                isRecording: recorder.recordingID == shortcut.id,
                startRecording: startRecording,
                stopRecording: recorder.stop
            )

            Button(action: remove) {
                Image(systemName: "trash")
                    .foregroundStyle(isHoveringRemove ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
            }
            .buttonStyle(.plain)
            .help("Remove \(shortcut.appName)")
            .onHover { isHoveringRemove = $0 }
        }
        .padding(.vertical, 3)
    }

    private func startRecording() {
        recorder.start(id: shortcut.id) { keyCode in
            guard let label = KeyBinding.label(forKeyCode: keyCode, layout: layout) else {
                return false
            }

            keyLabel = label
            return true
        }
    }

    private var isMissing: Bool {
        !FileManager.default.fileExists(atPath: shortcut.appPath)
    }

    private var icon: NSImage {
        DockAppIconProvider.icon(
            for: URL(fileURLWithPath: shortcut.appPath),
            appName: shortcut.appName,
            size: 32
        )
    }

    private var statusText: String {
        isMissing ? "App not found at saved path" : shortcut.appPath
    }
}

/// A swap changes an app the user was not editing, so it has to be reported rather than done silently.
private struct KeySwapToast: View {
    let swap: FixedAppKeySwap

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(swap.assignedAppName) now uses \(swap.assignedKeyLabel)")
                    .font(.callout.weight(.medium))

                Text("\(swap.displacedAppName) took \(swap.displacedKeyLabel) in the swap")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.08))
        )
        .shadow(color: .black.opacity(0.18), radius: 10, y: 3)
    }
}

/// Click to arm, then press the physical key you want. Picking from a list of 26 letters is busywork.
private struct KeyCaptureButton: View {
    let keyLabel: String
    let appName: String
    let isRecording: Bool
    let startRecording: () -> Void
    let stopRecording: () -> Void

    var body: some View {
        Button {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            if isRecording {
                Text("Press a key")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(height: 22)
                    .padding(.horizontal, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.accentColor)
                    )
            } else {
                KeyCapView(text: keyLabel, size: 22)
            }
        }
        .buttonStyle(.plain)
        .help(isRecording
            ? "Press a letter to assign it, or Esc to cancel"
            : "Click, then press the letter you want for \(appName)")
    }
}
