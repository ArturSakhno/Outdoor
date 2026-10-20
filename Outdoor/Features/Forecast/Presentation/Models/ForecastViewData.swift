enum RatingTone: Equatable {
    case great
    case good
    case fair
    case poor
    case none
}

struct ActivityCardViewData: Equatable, Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let bestDays: String
    let note: String?
    let days: [DayViewData]
}

struct DayViewData: Equatable, Identifiable {
    let id: String
    let label: String
    let rating: String
    let tone: RatingTone
    let detail: DayDetailViewData
}

struct DayDetailViewData: Equatable, Identifiable {
    struct Row: Equatable, Identifiable {
        let title: String
        let value: String

        var id: String { title }
    }

    let id: String
    let title: String
    let activity: String
    let rating: String
    let tone: RatingTone
    let reasons: [String]
    let rows: [Row]
}
