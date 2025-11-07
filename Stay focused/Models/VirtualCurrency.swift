//
//  VirtualCurrency.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation

struct VirtualCurrency: Codable {
    var coins: Int // Monedas virtuales
    
    init(coins: Int = 0) {
        self.coins = coins
    }
    
    // Recompensas por acciones
    static let rewardForTaskCompletion = 50
    static let rewardForCheckIn = 10
    static let rewardForStreak = 25
    static let rewardForBadge = 100
    
    // Costos de compras
    static let costForHealthBoost = 20
    static let costForHappinessBoost = 20
    static let costForXPBoost = 30
}

