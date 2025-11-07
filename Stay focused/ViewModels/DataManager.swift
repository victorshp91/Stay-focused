//
//  DataManager.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation

struct AppData: Codable {
    var tasks: [Task]
    var pets: [Pet]
    var streak: Streak
    var badges: [Badge]
    var settings: UserSettings
    var currentPetId: UUID? // ID de la mascota activa
    var virtualCurrency: VirtualCurrency? // Moneda virtual
    var totalPoints: Int?
    var completedTasksCount: Int?
    var successfulCheckInsCount: Int?
    var consecutiveSuccessfulCheckIns: Int?
}

class DataManager {
    static let shared = DataManager()
    
    private let fileName = "app_data.json"
    
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    func save(tasks: [Task], pets: [Pet], streak: Streak, badges: [Badge], settings: UserSettings, currentPetId: UUID? = nil, virtualCurrency: VirtualCurrency? = nil, totalPoints: Int = 0, completedTasksCount: Int = 0, successfulCheckInsCount: Int = 0, consecutiveSuccessfulCheckIns: Int = 0) {
        var data = AppData(tasks: tasks, pets: pets, streak: streak, badges: badges, settings: settings)
        data.currentPetId = currentPetId
        data.virtualCurrency = virtualCurrency
        data.totalPoints = totalPoints
        data.completedTasksCount = completedTasksCount
        data.successfulCheckInsCount = successfulCheckInsCount
        data.consecutiveSuccessfulCheckIns = consecutiveSuccessfulCheckIns
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error guardando datos: \(error)")
        }
    }
    
    func load() -> (tasks: [Task], pets: [Pet], streak: Streak, badges: [Badge], settings: UserSettings, currentPetId: UUID?, virtualCurrency: VirtualCurrency?, totalPoints: Int, completedTasksCount: Int, successfulCheckInsCount: Int, consecutiveSuccessfulCheckIns: Int)? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let appData = try decoder.decode(AppData.self, from: data)
            return (
                tasks: appData.tasks,
                pets: appData.pets,
                streak: appData.streak,
                badges: appData.badges,
                settings: appData.settings,
                currentPetId: appData.currentPetId,
                virtualCurrency: appData.virtualCurrency,
                totalPoints: appData.totalPoints ?? 0,
                completedTasksCount: appData.completedTasksCount ?? 0,
                successfulCheckInsCount: appData.successfulCheckInsCount ?? 0,
                consecutiveSuccessfulCheckIns: appData.consecutiveSuccessfulCheckIns ?? 0
            )
        } catch {
            print("Error cargando datos: \(error)")
            return nil
        }
    }
}

