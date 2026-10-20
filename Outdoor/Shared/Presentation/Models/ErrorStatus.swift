enum ErrorStatus: Equatable {
    case offline
    case unavailable
}

extension ErrorStatus {
    init(_ error: ServiceError) {
        switch error {
        case .offline: self = .offline
        case .unavailable: self = .unavailable
        }
    }
}
