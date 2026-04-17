import SwiftUI

struct SwitcherItem: Identifiable, Hashable {
    let app: DockApp
    let keyBinding: KeyBinding

    var id: String { app.id }
}

struct SwitcherBarView: View {
    let items: [SwitcherItem]
    let showsAppNames: Bool
    let metrics: SwitcherBarMetrics

    var body: some View {
        HStack(spacing: metrics.spacing) {
            ForEach(items) { item in
                SwitcherItemView(
                    item: item,
                    showsAppName: showsAppNames,
                    metrics: metrics
                )
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.vertical, metrics.verticalPadding)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

struct SwitcherBarMetrics {
    let panelWidth: CGFloat
    let panelHeight: CGFloat
    let itemWidth: CGFloat
    let iconSize: CGFloat
    let badgeSize: CGFloat
    let badgeFontSize: CGFloat
    let nameFontSize: CGFloat
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat

    static func make(
        itemCount: Int,
        availableWidth: CGFloat,
        showsAppNames: Bool
    ) -> SwitcherBarMetrics {
        let count = CGFloat(max(itemCount, 1))
        let horizontalPadding: CGFloat = 14
        let verticalPadding: CGFloat = 16
        let preferredItemWidth: CGFloat = 96
        let preferredSpacing: CGFloat = 3
        let compactSpacing: CGFloat = 1
        let preferredContentWidth = count * preferredItemWidth + max(0, count - 1) * preferredSpacing
        let preferredPanelWidth = preferredContentWidth + horizontalPadding * 2

        let panelWidth = min(availableWidth, preferredPanelWidth)
        let contentWidth = max(1, panelWidth - horizontalPadding * 2)
        let spacing = preferredPanelWidth <= availableWidth ? preferredSpacing : compactSpacing
        let itemWidth = max(1, (contentWidth - max(0, count - 1) * spacing) / count)
        let iconSize = min(72, max(22, itemWidth - 18))
        let badgeSize = min(24, max(14, iconSize * 0.34))
        let badgeFontSize = min(13, max(8, badgeSize * 0.52))
        let nameFontSize = min(11, max(8, itemWidth * 0.16))
        let nameHeight: CGFloat = showsAppNames ? 16 : 0
        let nameGap: CGFloat = showsAppNames ? 7 : 0
        let panelHeight = verticalPadding * 2 + iconSize + nameGap + nameHeight

        return SwitcherBarMetrics(
            panelWidth: panelWidth,
            panelHeight: panelHeight,
            itemWidth: itemWidth,
            iconSize: iconSize,
            badgeSize: badgeSize,
            badgeFontSize: badgeFontSize,
            nameFontSize: nameFontSize,
            spacing: spacing,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
    }
}

private struct SwitcherItemView: View {
    let item: SwitcherItem
    let showsAppName: Bool
    let metrics: SwitcherBarMetrics

    var body: some View {
        VStack(spacing: 7) {
            ZStack(alignment: .topLeading) {
                Image(nsImage: item.app.icon)
                    .resizable()
                    .frame(width: metrics.iconSize, height: metrics.iconSize)

                Text(item.keyBinding.label)
                    .font(.system(size: metrics.badgeFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: metrics.badgeSize, height: metrics.badgeSize)
                    .background(Color.black.opacity(0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .offset(x: metrics.badgeSize * 0.04, y: metrics.badgeSize * 0.04)
            }
            .frame(width: metrics.itemWidth, height: metrics.iconSize)

            if showsAppName {
                Text(item.app.name)
                    .font(.system(size: metrics.nameFontSize, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: metrics.itemWidth)
            }
        }
        .frame(width: metrics.itemWidth)
    }
}
