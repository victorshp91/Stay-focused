//
//  Pet.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation

struct Pet: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: PetType
    var health: Int // 0-100
    var happiness: Int // 0-100
    var level: Int
    var experience: Int
    var isPremium: Bool
    var isUnlocked: Bool
    var lastFed: Date?
    var consecutiveDays: Int
    var lastDeteriorationDate: Date? // Última fecha en que se aplicó deterioro
    var completedTaskIds: [UUID] // IDs de tareas completadas con esta mascota
    var deathDate: Date? // Fecha de muerte (si la mascota murió)
    
    init(id: UUID = UUID(), name: String, type: PetType, isPremium: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.health = 100
        self.happiness = 100
        self.level = 1
        self.experience = 0
        self.isPremium = isPremium
        self.isUnlocked = !isPremium
        self.lastFed = nil
        self.consecutiveDays = 0
        self.lastDeteriorationDate = nil
        self.completedTaskIds = []
        self.deathDate = nil
    }
    
    var isAlive: Bool {
        health > 0 && deathDate == nil
    }
    
    var healthStatus: HealthStatus {
        if health >= 80 { return .healthy }
        if health >= 50 { return .okay }
        if health >= 20 { return .sick }
        return .critical
    }
    
    mutating func feed() {
        health = min(100, health + 10)
        happiness = min(100, happiness + 5)
        lastFed = Date()
        // Resetear el contador de deterioro cuando se alimenta
        lastDeteriorationDate = nil
    }
    
    mutating func neglect() {
        health = max(0, health - 15)
        happiness = max(0, happiness - 10)
    }
    
    // Experiencia base por acción
    static let baseExperience = 10
    
    // Calcular experiencia requerida para el siguiente nivel (progresivo)
    var experienceRequired: Int {
        // Fórmula progresiva: base * (nivel^1.5)
        // Nivel 1: ~10 exp, Nivel 5: ~56 exp, Nivel 10: ~158 exp, Nivel 25: ~625 exp
        let baseExp = 10.0
        let multiplier = pow(Double(level), 1.5)
        return Int(baseExp * multiplier)
    }
    
    // Nivel máximo
    static let maxLevel = 25
    
    mutating func reward(experienceGained: Int) {
        // Solo ganar experiencia si no está en nivel máximo
        guard level < Self.maxLevel else { return }
        
        experience += experienceGained
        happiness = min(100, happiness + 5)
        
        // Verificar si sube de nivel
        while experience >= experienceRequired && level < Self.maxLevel {
            experience -= experienceRequired
            level += 1
            // Bonificación al subir de nivel: recuperar algo de salud
            health = min(100, health + 5)
            happiness = min(100, happiness + 10)
        }
        
        // Si está en nivel máximo, no puede ganar más experiencia
        if level >= Self.maxLevel {
            experience = 0
        }
    }
}

enum PetType: String, Codable, CaseIterable {
    case cat = "Gato"
    case dog = "Perro"
    case rabbit = "Conejo"
    case dragon = "Dragón"
    case unicorn = "Unicornio"
    case phoenix = "Fénix"
    case robot = "Robot"
    case alien = "Alien"
    
    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .rabbit: return "🐰"
        case .dragon: return "🐉"
        case .unicorn: return "🦄"
        case .phoenix: return "🔥"
        case .robot: return "🤖"
        case .alien: return "👽"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .cat, .dog, .rabbit: return false
        default: return true
        }
    }
    
    // Precio de cada mascota (en dólares)
    var price: Double {
        switch self {
        case .cat: return 0.0 // Gratis
        case .dog: return 1.99
        case .rabbit: return 1.99
        case .dragon: return 2.99
        case .unicorn: return 2.99
        case .phoenix: return 3.99
        case .robot: return 2.99
        case .alien: return 3.99
        }
    }
    
    // Formatear precio
    var formattedPrice: String {
        if price == 0.0 {
            return "Gratis"
        } else {
            return String(format: "$%.2f", price)
        }
    }
}

enum HealthStatus: String {
    case healthy = "Saludable"
    case okay = "Bien"
    case sick = "Enfermo"
    case critical = "Crítico"
}

