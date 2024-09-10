//
//  Errors.swift
//  SquadShuffler
//
//  Created by Anthony Khera on 9/5/24.
//

import Foundation

enum AppErrors: Error, LocalizedError {
    case tooManyPlaying
    case notEnoughParticipants
    case tooManySitting
    case defaultError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notEnoughParticipants:
            "Not Enough Participants"
        case .tooManyPlaying:
            "Too Many Playing"
        case .tooManySitting:
            "Too Many Sitting"
        case .defaultError(let error):
            error.localizedDescription
        }
    }
    
    var failureReason: String {
        switch self {
        case .notEnoughParticipants:
            return "Not enough participants to continue. Please adjust your game settings or select more particpants."
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
}
