//
//  GameColorTheme.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct GameColorTheme {
    // Paleta de colores principal armoniosa
    static let primaryGradient = [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)]
    static let secondaryGradient = [Color(red: 1.0, green: 0.5, blue: 0.6), Color(red: 1.0, green: 0.7, blue: 0.4)]
    static let accentGradient = [Color(red: 0.4, green: 0.9, blue: 0.7), Color(red: 0.2, green: 0.8, blue: 1.0)]
    
    // Fondos por sección
    static func homeBackground() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.9, blue: 1.0),
                Color(red: 0.9, green: 0.95, blue: 1.0),
                Color(red: 0.85, green: 0.9, blue: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func petBackground() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.98, blue: 1.0),
                Color(red: 0.9, green: 0.95, blue: 1.0),
                Color(red: 0.85, green: 0.9, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func streakBackground() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.95, blue: 0.9),
                Color(red: 1.0, green: 0.9, blue: 0.85),
                Color(red: 0.98, green: 0.85, blue: 0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func rewardsBackground() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.92, blue: 0.98),
                Color(red: 0.98, green: 0.9, blue: 1.0),
                Color(red: 0.95, green: 0.88, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func settingsBackground() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.96, blue: 0.98),
                Color(red: 0.94, green: 0.94, blue: 0.96),
                Color(red: 0.92, green: 0.92, blue: 0.94)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Colores de estado
    static let successColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warningColor = Color(red: 1.0, green: 0.7, blue: 0.2)
    static let dangerColor = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let infoColor = Color(red: 0.2, green: 0.6, blue: 1.0)
}

