import DesignSystem
import SwiftUI

struct SearchScreen: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        content
            .navigationTitle("Outdoor")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "City or town"
            )
            .autocorrectionDisabled()
            .task(id: viewModel.searchTrigger) {
                await viewModel.search()
            }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Find a place",
                systemImage: DS.Icon.search,
                description: Text("See how the next 7 days look for skiing, surfing and sightseeing.")
            )
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .results(rows):
            List(rows) { row in
                Button {
                    viewModel.select(row)
                } label: {
                    PlaceRow(viewData: row)
                }
                .tint(DS.Color.textPrimary)
            }
            .listStyle(.plain)
        case .empty:
            ContentUnavailableView.search(text: viewModel.trimmedQuery)
        case let .failed(error):
            StatusView(error: error, onRetry: viewModel.retry)
        }
    }
}

private struct PlaceRow: View {
    let viewData: PlaceRowViewData

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxxs) {
            Text(viewData.name)
                .textStyle(.body)
            if let subtitle = viewData.subtitle {
                Text(subtitle)
                    .textStyle(.bodySmall)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SearchScreen(viewModel: DependencyContainer().makeSearchViewModel())
    }
}
#endif
