//
//  Errors.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//

import Foundation

enum AppErrors: Error, LocalizedError, Equatable {
    case tooManyPlaying
    case notEnoughParticipants
    case tooManySitting
    case defaultError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notEnoughParticipants:
            return "Not Enough Participants"
        case .tooManyPlaying:
            return "Too Many Playing"
        case .tooManySitting:
            return "Too Many Sitting"
        case .defaultError(let error):
            return error.localizedDescription
        }
    }
    
    var failureReason: String {
        switch self {
        case .notEnoughParticipants:
            return "Not enough participants to continue. Please adjust your game settings or select more participants."
        case .tooManyPlaying:
            return "Too many participants set to play. Please adjust your game settings or designate fewer participants."
        case .tooManySitting:
            return "Too many participants set to sit. Please adjust your game settings or designate fewer participants."
        case .defaultError(let error):
            if let localizedError = error as? LocalizedError, let reason = localizedError.failureReason {
                return reason
            }
            return "An unknown error occurred."
        }
    }
    
    static func == (lhs: AppErrors, rhs: AppErrors) -> Bool {
        switch (lhs, rhs) {
        case (.tooManyPlaying, .tooManyPlaying),
             (.notEnoughParticipants, .notEnoughParticipants),
             (.tooManySitting, .tooManySitting):
            return true
        case (.defaultError, .defaultError):
            return false // Since `Error` doesn't conform to `Equatable`, we consider two `.defaultError` cases as non-equal.
        default:
            return false
        }
    }
}

