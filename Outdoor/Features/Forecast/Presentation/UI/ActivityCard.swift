import DesignSystem
import SwiftUI

struct ActivityCard: View {
    let viewData: ActivityCardViewData
    let onSelectDay: (DayViewData) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Label(viewData.title, systemImage: viewData.systemImage)
                .textStyle(.title)

            Text(viewData.bestDays)
                .textStyle(.bodySmall)

            HStack(spacing: DS.Spacing.xxs) {
                ForEach(viewData.days) { day in
                    DayChip(viewData: day) {
                        onSelectDay(day)
                    }
                }
            }

            if let note = viewData.note {
                Text(note)
                    .textStyle(.caption)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .padding(DS.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Color.surfaceCard, in: .rect(cornerRadius: DS.Radius.card))
    }
}

private struct DayChip: View {
    let viewData: DayViewData
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xxs) {
                Text(viewData.label)
                    .textStyle(.captionSmall)
                    .foregroundStyle(DS.Color.textSecondary)
                Text(viewData.rating)
                    .textStyle(.captionStrong)
                    .foregroundStyle(viewData.tone.color)
            }
            .lineLimit(1)
            .minimumScaleFactor(DS.minimumChipTextScale)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.xs)
            .background(viewData.tone.color.opacity(DS.Opacity.tint), in: .rect(cornerRadius: DS.Radius.chip))
        }
        .buttonStyle(.plain)
    }
}
