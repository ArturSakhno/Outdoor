import DesignSystem
import SwiftUI

extension RatingTone {
    var color: Color {
        switch self {
        case .great: DS.Color.ratingGreat
        case .good: DS.Color.ratingGood
        case .fair: DS.Color.ratingFair
        case .poor: DS.Color.ratingPoor
        case .none: DS.Color.ratingNone
        }
    }
}
