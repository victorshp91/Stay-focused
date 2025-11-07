//
//  Task.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var duration: TimeInterval // en segundos
    var checkInInterval: TimeInterval // intervalo entre check-ins en segundos
    var startTime: Date?
    var endTime: Date?
    var isActive: Bool
    var checkIns: [CheckIn]
    var petId: UUID? // ID de la mascota que está haciendo esta tarea
    
    init(id: UUID = UUID(), title: String, duration: TimeInterval, checkInInterval: TimeInterval, petId: UUID? = nil) {
        self.id = id
        self.title = title
        self.duration = duration
        self.checkInInterval = checkInInterval
        self.startTime = nil
        self.endTime = nil
        self.isActive = false
        self.checkIns = []
        self.petId = petId
    }
    
    var progress: Double {
        guard let startTime = startTime else { return 0.0 }
        let elapsed = Date().timeIntervalSince(startTime)
        return min(elapsed / duration, 1.0)
    }
    
    var nextCheckInTime: Date? {
        guard let startTime = startTime else { return nil }
        let lastCheckIn = checkIns.last?.timestamp ?? startTime
        return lastCheckIn.addingTimeInterval(checkInInterval)
    }
    
    var nextCheckInDeadline: Date? {
        guard let nextCheckIn = nextCheckInTime else { return nil }
        // Sistema híbrido: 20% del intervalo, mínimo 2 min, máximo 10 min
        let windowPercentage = 0.2 // 20%
        var windowTime = checkInInterval * windowPercentage
        
        // Aplicar límites: mínimo 2 minutos, máximo 10 minutos
        let minWindow: TimeInterval = 2 * 60 // 2 minutos
        let maxWindow: TimeInterval = 10 * 60 // 10 minutos
        
        windowTime = max(minWindow, min(windowTime, maxWindow))
        
        return nextCheckIn.addingTimeInterval(windowTime)
    }
    
    var isCheckInDue: Bool {
        guard let nextCheckIn = nextCheckInTime else { return false }
        return Date() >= nextCheckIn
    }
    
    var isCheckInOverdue: Bool {
        guard let deadline = nextCheckInDeadline else { return false }
        return Date() >= deadline
    }
    
    var timeRemainingForCheckIn: TimeInterval? {
        guard let deadline = nextCheckInDeadline, isCheckInDue else { return nil }
        let remaining = deadline.timeIntervalSinceNow
        return remaining > 0 ? remaining : 0
    }
    
    var isCompleted: Bool {
        guard let endTime = endTime else { return false }
        return Date() >= endTime && isActive
    }
    
    var allCheckInsVerified: Bool {
        guard !checkIns.isEmpty else { return false }
        return checkIns.allSatisfy { $0.isVerified }
    }
    
    var completionRate: Double {
        guard let startTime = startTime, let endTime = endTime else { return 0.0 }
        let expectedCheckIns = Int(duration / checkInInterval)
        guard expectedCheckIns > 0 else { return 0.0 }
        let verifiedCheckIns = checkIns.filter { $0.isVerified }.count
        return Double(verifiedCheckIns) / Double(expectedCheckIns)
    }
}

struct CheckIn: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    var photoData: Data?
    var isVerified: Bool
    var verificationResult: VerificationResult?
    
    init(id: UUID = UUID(), timestamp: Date = Date(), photoData: Data? = nil, isVerified: Bool = false) {
        self.id = id
        self.timestamp = timestamp
        self.photoData = photoData
        self.isVerified = isVerified
        self.verificationResult = nil
    }
}

enum VerificationResult: String, Codable {
    case verified = "Verificado"
    case failed = "Fallido"
    case pending = "Pendiente"
    case missed = "Perdido"
}

