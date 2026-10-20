import SwiftUI
import UIKit

public extension DS {
    enum Color {
        public static let textPrimary = SwiftUI.Color.primary
        public static let textSecondary = SwiftUI.Color.secondary

        public static let surfaceCard = SwiftUI.Color(uiColor: .secondarySystemBackground)

        public static let ratingGreat = SwiftUI.Color.green
        public static let ratingGood = SwiftUI.Color.teal
        public static let ratingFair = SwiftUI.Color.orange
        public static let ratingPoor = SwiftUI.Color.red
        public static let ratingNone = SwiftUI.Color.secondary
    }
}
