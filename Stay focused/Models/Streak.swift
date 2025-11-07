//
//  Streak.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation

struct Streak: Identifiable, Codable {
    let id: UUID
    var currentStreak: Int // días consecutivos
    var longestStreak: Int
    var lastActivityDate: Date?
    var totalDays: Int
    
    init(id: UUID = UUID()) {
        self.id = id
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActivityDate = nil
        self.totalDays = 0
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastActivityDate else {
            // Primera vez
            currentStreak = 1
            longestStreak = 1
            lastActivityDate = today
            totalDays = 1
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Mismo día, no hacer nada
            return
        } else if daysDifference == 1 {
            // Día consecutivo
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            // Se rompió la racha
            currentStreak = 1
        }
        
        lastActivityDate = today
        totalDays += 1
    }
    
    var milestone: StreakMilestone {
        if currentStreak >= 100 { return .century }
        if currentStreak >= 50 { return .gold }
        if currentStreak >= 30 { return .silver }
        if currentStreak >= 14 { return .bronze }
        if currentStreak >= 7 { return .week }
        if currentStreak >= 3 { return .threeDays }
        return .none
    }
}

enum StreakMilestone: Int, CaseIterable {
    case none = 0
    case threeDays = 3
    case week = 7
    case bronze = 14
    case silver = 30
    case gold = 50
    case century = 100
    
    var badge: String {
        switch self {
        case .none: return ""
        case .threeDays: return "🥉"
        case .week: return "🏅"
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .century: return "💎"
        }
    }
    
    var name: String {
        switch self {
        case .none: return ""
        case .threeDays: return "3 Días"
        case .week: return "1 Semana"
        case .bronze: return "2 Semanas"
        case .silver: return "1 Mes"
        case .gold: return "50 Días"
        case .century: return "100 Días"
        }
    }
}

