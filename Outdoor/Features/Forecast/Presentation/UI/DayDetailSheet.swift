import DesignSystem
import SwiftUI

struct DayDetailSheet: View {
    let viewData: DayDetailViewData

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent(viewData.activity) {
                        Text(viewData.rating)
                            .textStyle(.title)
                            .foregroundStyle(viewData.tone.color)
                    }
                    ForEach(viewData.reasons, id: \.self) { reason in
                        Text(reason)
                    }
                }

                Section("Forecast") {
                    ForEach(viewData.rows) { row in
                        LabeledContent(row.title, value: row.value)
                    }
                }
            }
            .navigationTitle(viewData.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
