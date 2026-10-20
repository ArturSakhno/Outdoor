import DesignSystem
import SwiftUI

struct PlaceScreen: View {
    private enum Constants {
        static let attributionURL = URL(string: "https://open-meteo.com/")
    }

    @State private var viewModel: PlaceViewModel

    init(viewModel: PlaceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                header
                content
            }
            .padding(DS.Spacing.m)
        }
        .navigationTitle(viewModel.title)
        .task(id: viewModel.retryCount) {
            await viewModel.load()
        }
        .sheet(item: $viewModel.selectedDay, content: DayDetailSheet.init)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
            if let subtitle = viewModel.subtitle {
                Text(subtitle)
                    .foregroundStyle(DS.Color.textSecondary)
            }
            if case let .loaded(content) = viewModel.state {
                Text(content.elevation)
                    .textStyle(.footnote)
                    .foregroundStyle(DS.Color.textSecondary)
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, DS.Spacing.statusTop)
        case let .loaded(content):
            ForEach(content.activities) { activity in
                ActivityCard(viewData: activity, onSelectDay: viewModel.select)
            }
            attribution
        case let .failed(error):
            StatusView(error: error, onRetry: viewModel.retry)
                .padding(.top, DS.Spacing.statusTop)
        }
    }

    @ViewBuilder
    private var attribution: some View {
        if let url = Constants.attributionURL {
            Link("Weather data by Open-Meteo.com", destination: url)
                .textStyle(.footnote)
                .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PlaceScreen(viewModel: .preview())
    }
}
#endif
