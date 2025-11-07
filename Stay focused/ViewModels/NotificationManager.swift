//
//  NotificationManager.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    // Programar notificaciones para todos los check-ins de una tarea
    func scheduleCheckInNotifications(for task: Task) {
        guard let startTime = task.startTime else { return }
        
        // Cancelar notificaciones anteriores de esta tarea
        cancelCheckInNotifications(for: task.id)
        
        // Calcular todos los check-ins futuros
        let checkInInterval = task.checkInInterval
        let taskDuration = task.duration
        let expectedCheckIns = Int(taskDuration / checkInInterval)
        
        // Calcular la ventana de tiempo para cada check-in
        let windowPercentage = 0.2
        var windowTime = checkInInterval * windowPercentage
        let minWindow: TimeInterval = 2 * 60 // 2 minutos
        let maxWindow: TimeInterval = 10 * 60 // 10 minutos
        windowTime = max(minWindow, min(windowTime, maxWindow))
        
        for i in 0..<expectedCheckIns {
            let checkInTime = startTime.addingTimeInterval(checkInInterval * Double(i + 1))
            let deadline = checkInTime.addingTimeInterval(windowTime)
            
            // Solo programar si el check-in es en el futuro
            if checkInTime > Date() {
                // Notificación para cuando es hora del check-in
                scheduleCheckInDueNotification(
                    taskId: task.id,
                    taskTitle: task.title,
                    checkInTime: checkInTime,
                    checkInNumber: i + 1
                )
                
                // Notificación para cuando se pasa el deadline
                scheduleCheckInDeadlineNotification(
                    taskId: task.id,
                    taskTitle: task.title,
                    deadline: deadline,
                    checkInNumber: i + 1
                )
            }
        }
        
        // Programar notificación de finalización de tarea
        if let endTime = task.endTime, endTime > Date() {
            scheduleTaskCompletionNotification(
                taskId: task.id,
                taskTitle: task.title,
                endTime: endTime
            )
        }
    }
    
    private func scheduleCheckInDueNotification(taskId: UUID, taskTitle: String, checkInTime: Date, checkInNumber: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Check-in Requerido"
        content.body = "Es hora de hacer el check-in #\(checkInNumber) para '\(taskTitle)'"
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "taskId": taskId.uuidString,
            "type": "checkInDue",
            "checkInNumber": checkInNumber
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(0, checkInTime.timeIntervalSinceNow),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "checkInDue_\(taskId.uuidString)_\(checkInNumber)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling check-in notification: \(error)")
            }
        }
    }
    
    private func scheduleCheckInDeadlineNotification(taskId: UUID, taskTitle: String, deadline: Date, checkInNumber: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Check-in Perdido"
        content.body = "Se perdió el check-in #\(checkInNumber) para '\(taskTitle)'. Tu mascota ha sido penalizada."
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "taskId": taskId.uuidString,
            "type": "checkInMissed",
            "checkInNumber": checkInNumber
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(0, deadline.timeIntervalSinceNow),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "checkInDeadline_\(taskId.uuidString)_\(checkInNumber)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling check-in deadline notification: \(error)")
            }
        }
    }
    
    private func scheduleTaskCompletionNotification(taskId: UUID, taskTitle: String, endTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Tarea Completada"
        content.body = "La tarea '\(taskTitle)' ha sido completada. ¡Buen trabajo!"
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "taskId": taskId.uuidString,
            "type": "taskCompleted"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(0, endTime.timeIntervalSinceNow),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "taskCompletion_\(taskId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling task completion notification: \(error)")
            }
        }
    }
    
    // Cancelar todas las notificaciones de una tarea
    func cancelCheckInNotifications(for taskId: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { request in
                    if let taskIdString = request.content.userInfo["taskId"] as? String {
                        return taskIdString == taskId.uuidString
                    }
                    return false
                }
                .map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // Cancelar todas las notificaciones
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

