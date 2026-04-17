import SwiftUI

struct SwitcherItem: Identifiable, Hashable {
    let app: DockApp
    let keyBinding: KeyBinding

    var id: String { app.id }
}

struct SwitcherBarView: View {
    let items: [SwitcherItem]
    let showsAppNames: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    SwitcherItemView(item: item, showsAppName: showsAppNames)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct SwitcherItemView: View {
    let item: SwitcherItem
    let showsAppName: Bool

    var body: some View {
        VStack(spacing: 7) {
            ZStack(alignment: .topLeading) {
                Image(nsImage: item.app.icon)
                    .resizable()
                    .frame(width: 46, height: 46)

                Text(item.keyBinding.label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 19, height: 19)
                    .background(Color.black.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .offset(x: -7, y: -7)
            }
            .frame(width: 58, height: 52)

            if showsAppName {
                Text(item.app.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 68)
            }
        }
        .frame(width: 72, height: showsAppName ? 86 : 62)
    }
}
