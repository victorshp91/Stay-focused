//
//  Badge.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation
import SwiftUI

struct Badge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var emoji: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var category: BadgeCategory
    var rarity: BadgeRarity
    var points: Int // Puntos que otorga al desbloquearse
    
    init(id: UUID = UUID(), name: String, description: String, emoji: String, category: BadgeCategory, rarity: BadgeRarity = .common, points: Int = 10) {
        self.id = id
        self.name = name
        self.description = description
        self.emoji = emoji
        self.isUnlocked = false
        self.unlockedDate = nil
        self.category = category
        self.rarity = rarity
        self.points = points
    }
}

enum BadgeRarity: String, Codable {
    case common = "Común"
    case rare = "Raro"
    case epic = "Épico"
    case legendary = "Legendario"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var glowColor: Color {
        switch self {
        case .common: return .gray.opacity(0.3)
        case .rare: return .blue.opacity(0.5)
        case .epic: return .purple.opacity(0.6)
        case .legendary: return .orange.opacity(0.7)
        }
    }
}

enum BadgeCategory: String, Codable {
    case streak = "Rachas"
    case completion = "Completación"
    case consistency = "Consistencia"
    case special = "Especial"
}

struct BadgeCollection {
    static let allBadges: [Badge] = [
        // Completación - Comunes
        Badge(name: "Primer Paso", description: "Completa tu primera tarea", emoji: "🎯", category: .completion, rarity: .common, points: 10),
        Badge(name: "Aprendiz", description: "Completa 5 tareas", emoji: "📚", category: .completion, rarity: .common, points: 15),
        Badge(name: "Estudiante", description: "Completa 10 tareas", emoji: "🎓", category: .completion, rarity: .rare, points: 25),
        Badge(name: "Experto", description: "Completa 25 tareas", emoji: "⭐", category: .completion, rarity: .rare, points: 50),
        Badge(name: "Maestro", description: "Completa 50 tareas", emoji: "👑", category: .completion, rarity: .epic, points: 100),
        Badge(name: "Leyenda", description: "Completa 100 tareas", emoji: "🏆", category: .completion, rarity: .legendary, points: 250),
        
        // Rachas - Variadas
        Badge(name: "Iniciando", description: "3 días consecutivos", emoji: "🔥", category: .streak, rarity: .common, points: 15),
        Badge(name: "Semana Perfecta", description: "7 días consecutivos", emoji: "🏅", category: .streak, rarity: .rare, points: 30),
        Badge(name: "Dos Semanas", description: "14 días consecutivos", emoji: "🥉", category: .streak, rarity: .rare, points: 50),
        Badge(name: "Un Mes", description: "30 días consecutivos", emoji: "🥈", category: .streak, rarity: .epic, points: 100),
        Badge(name: "50 Días", description: "50 días consecutivos", emoji: "🥇", category: .streak, rarity: .epic, points: 150),
        Badge(name: "Centenario", description: "100 días consecutivos", emoji: "💎", category: .streak, rarity: .legendary, points: 300),
        Badge(name: "Invencible", description: "200 días consecutivos", emoji: "⚡", category: .streak, rarity: .legendary, points: 500),
        
        // Consistencia - Variadas
        Badge(name: "Puntual", description: "Completa 10 check-ins a tiempo", emoji: "⏰", category: .consistency, rarity: .common, points: 20),
        Badge(name: "Precisión", description: "Completa 25 check-ins a tiempo", emoji: "🎯", category: .consistency, rarity: .rare, points: 40),
        Badge(name: "Perfecto", description: "Completa 50 check-ins a tiempo", emoji: "✨", category: .consistency, rarity: .epic, points: 75),
        Badge(name: "Sin Errores", description: "Completa 100 check-ins a tiempo", emoji: "💯", category: .consistency, rarity: .legendary, points: 200),
        Badge(name: "Ritmo Constante", description: "10 check-ins consecutivos exitosos", emoji: "🎪", category: .consistency, rarity: .rare, points: 35),
        Badge(name: "Máxima Eficiencia", description: "25 check-ins consecutivos exitosos", emoji: "🚀", category: .consistency, rarity: .epic, points: 80),
        
        // Especiales - Épicas y Legendarias
        Badge(name: "Protector", description: "Mantén tu mascota saludable por 30 días", emoji: "🛡️", category: .special, rarity: .epic, points: 100),
        Badge(name: "Cuidador Experto", description: "Mantén tu mascota en nivel máximo por 7 días", emoji: "💚", category: .special, rarity: .epic, points: 120),
        Badge(name: "Maestro de Mascotas", description: "Lleva una mascota al nivel 25", emoji: "👑", category: .special, rarity: .legendary, points: 300),
        Badge(name: "Coleccionista", description: "Desbloquea 5 mascotas diferentes", emoji: "🎨", category: .special, rarity: .rare, points: 60),
        Badge(name: "Sobreviviente", description: "Completa una tarea sin perder ningún check-in", emoji: "🎖️", category: .special, rarity: .rare, points: 40),
        Badge(name: "Invencible", description: "Completa 10 tareas sin perder ningún check-in", emoji: "⚔️", category: .special, rarity: .epic, points: 150),
        Badge(name: "Fénix", description: "Crea una nueva mascota después de que una muera", emoji: "🔥", category: .special, rarity: .epic, points: 80),
        Badge(name: "Dedicación Total", description: "Completa una tarea de 8 horas", emoji: "⛰️", category: .special, rarity: .epic, points: 100),
        Badge(name: "Velocidad", description: "Completa 5 tareas en un solo día", emoji: "⚡", category: .special, rarity: .legendary, points: 200),
        Badge(name: "Maestro del Tiempo", description: "Completa 100 check-ins en total", emoji: "⏱️", category: .special, rarity: .legendary, points: 250)
    ]
}

