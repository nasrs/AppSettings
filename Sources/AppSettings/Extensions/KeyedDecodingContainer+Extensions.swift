// Copyright © ICS 2024 from aiPhad.com

import Foundation

internal extension KeyedDecodingContainer {
    func decodeAnyIfPresent(forKey key: Key) -> String? {
        if let attemptString = try? decodeIfPresent(String.self, forKey: key) {
            return attemptString
        } else if let attemptBool = try? decodeIfPresent(Bool.self, forKey: key) {
            return "\(attemptBool)"
        } else if let attemptInt = try? decodeIfPresent(Int.self, forKey: key) {
            return "\(attemptInt)"
        } else if let attemptFloat = try? decodeIfPresent(Float.self, forKey: key) {
            return "\(attemptFloat)"
        }
        return nil
    }

    func decodeAnyListIfPresent(forKey key: Key) -> [String]? {
        if let attemptString = try? decodeIfPresent([String].self, forKey: key) {
            return attemptString.map { "\($0)" }
        } else if let attemptInt = try? decodeIfPresent([Int].self, forKey: key) {
            return attemptInt.map { "\($0)" }
        } else if let attemptFloat = try? decodeIfPresent([Float].self, forKey: key) {
            return attemptFloat.map { "\($0)" }
        }
        return nil
    }
}
