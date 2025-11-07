//
//  UserSettings.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation
import Combine

class UserSettings: ObservableObject, Codable {
    @Published var isPremium: Bool
    @Published var maxPets: Int {
        didSet {
            if !isPremium && maxPets > 1 {
                maxPets = 1
            }
        }
    }
    @Published var notificationsEnabled: Bool
    @Published var checkInReminders: Bool
    
    enum CodingKeys: String, CodingKey {
        case isPremium, maxPets, notificationsEnabled, checkInReminders
    }
    
    init(isPremium: Bool = false) {
        self.isPremium = isPremium
        self.maxPets = isPremium ? 10 : 1 // Solo 1 mascota gratis
        self.notificationsEnabled = true
        self.checkInReminders = true
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        maxPets = try container.decode(Int.self, forKey: .maxPets)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        checkInReminders = try container.decode(Bool.self, forKey: .checkInReminders)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(maxPets, forKey: .maxPets)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(checkInReminders, forKey: .checkInReminders)
    }
}

