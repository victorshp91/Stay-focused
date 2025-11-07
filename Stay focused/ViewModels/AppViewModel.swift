//
//  AppViewModel.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class AppViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var pets: [Pet] = []
    @Published var currentPet: Pet? {
        didSet {
            // Guardar automáticamente cuando cambia la mascota activa
            // Pero no durante la carga inicial de datos
            if !isLoadingData {
                saveData()
            }
        }
    }
    @Published var streak: Streak = Streak()
    @Published var badges: [Badge] = BadgeCollection.allBadges
    @Published var settings: UserSettings = UserSettings()
    @Published var activeTask: Task?
    @Published var totalPoints: Int = 0
    @Published var completedTasksCount: Int = 0
    @Published var successfulCheckInsCount: Int = 0
    @Published var consecutiveSuccessfulCheckIns: Int = 0
    @Published var virtualCurrency: VirtualCurrency = VirtualCurrency()
    
    private var checkInTimer: Timer?
    private var checkInDeadlineTimer: Timer?
    private var taskCompletionTimer: Timer?
    private var petHealthMonitorTimer: Timer?
    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared
    private var isLoadingData = false // Bandera para evitar guardar durante la carga inicial
    
    // Sistema híbrido: el tiempo límite se calcula dinámicamente
    // basado en el intervalo de check-in (20% del intervalo, min 2min, max 10min)
    
    init() {
        loadData()
        setupInitialPet()
        startPetHealthMonitor()
        checkAllBadges() // Verificar insignias al iniciar
        processActiveTaskOnAppLaunch() // Procesar tarea activa cuando la app se reabre
    }
    
    deinit {
        petHealthMonitorTimer?.invalidate()
    }
    
    func setupInitialPet() {
        if pets.isEmpty {
            var initialPet = Pet(name: "Mi Mascota", type: .cat)
            // Alimentar la mascota inicial para que no se deteriore inmediatamente
            initialPet.feed()
            pets.append(initialPet)
            currentPet = initialPet
            saveData()
        } else if currentPet == nil {
            // Solo establecer currentPet si no se restauró desde los datos guardados
            currentPet = pets.first
            // Si la mascota nunca ha sido alimentada, alimentarla ahora
            if let petIndex = pets.firstIndex(where: { $0.id == currentPet?.id }),
               pets[petIndex].lastFed == nil {
                pets[petIndex].feed()
                currentPet = pets[petIndex]
            }
            saveData()
        }
    }
    
    func startTask(_ task: Task) {
        // Verificar que no haya otra tarea activa
        if let existingActiveTask = activeTask {
            // Ya hay una tarea activa, no permitir iniciar otra
            return
        }
        
        // Verificar que haya una mascota activa
        guard let currentPet = currentPet, currentPet.isAlive else {
            return
        }
        
        var newTask = task
        newTask.startTime = Date()
        newTask.endTime = Date().addingTimeInterval(task.duration)
        newTask.isActive = true
        newTask.petId = currentPet.id // Asociar la tarea con la mascota actual
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = newTask
        } else {
            tasks.append(newTask)
        }
        
        activeTask = newTask
        
        // Programar notificaciones locales para cuando la app esté cerrada
        notificationManager.scheduleCheckInNotifications(for: newTask)
        
        startCheckInTimer()
        startCheckInDeadlineTimer()
        startTaskCompletionTimer()
        saveData()
    }
    
    func stopTask() {
        if let task = activeTask {
            completeTask(task)
        }
        // Cancelar notificaciones programadas
        if let taskId = activeTask?.id {
            notificationManager.cancelCheckInNotifications(for: taskId)
        }
        
        activeTask?.isActive = false
        checkInTimer?.invalidate()
        checkInTimer = nil
        checkInDeadlineTimer?.invalidate()
        checkInDeadlineTimer = nil
        taskCompletionTimer?.invalidate()
        taskCompletionTimer = nil
        activeTask = nil
    }
    
    func cancelTask() {
        guard let task = activeTask else { return }
        
        // Marcar la tarea como cancelada
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            var cancelledTask = tasks[taskIndex]
            cancelledTask.isActive = false
            
            // Marcar todos los check-ins pendientes como perdidos
            if let nextCheckIn = cancelledTask.nextCheckInTime {
                var missedCheckIn = CheckIn(
                    timestamp: nextCheckIn,
                    photoData: nil,
                    isVerified: false
                )
                missedCheckIn.verificationResult = .missed
                cancelledTask.checkIns.append(missedCheckIn)
            }
            
            tasks[taskIndex] = cancelledTask
        }
        
        // Penalizar a la mascota por cancelar la tarea
        // Penalización más severa que un check-in perdido
        if let petIndex = pets.firstIndex(where: { $0.id == currentPet?.id }) {
            // Penalización doble por cancelar
            pets[petIndex].neglect() // -15 salud, -10 felicidad
            pets[petIndex].neglect() // -15 salud más, -10 felicidad más
            currentPet = pets[petIndex]
            
            if !pets[petIndex].isAlive {
                NotificationCenter.default.post(name: .petDied, object: nil)
            }
        }
        
        // Cancelar notificaciones programadas
        if let taskId = activeTask?.id {
            notificationManager.cancelCheckInNotifications(for: taskId)
        }
        
        // Limpiar timers
        activeTask?.isActive = false
        checkInTimer?.invalidate()
        checkInTimer = nil
        checkInDeadlineTimer?.invalidate()
        checkInDeadlineTimer = nil
        taskCompletionTimer?.invalidate()
        taskCompletionTimer = nil
        activeTask = nil
        
        saveData()
        
        // Notificar que se canceló la tarea
        NotificationCenter.default.post(name: .taskCancelled, object: nil)
    }
    
    func startTaskCompletionTimer() {
        taskCompletionTimer?.invalidate()
        
        guard let task = activeTask, let endTime = task.endTime else { return }
        
        let timeUntilCompletion = endTime.timeIntervalSinceNow
        if timeUntilCompletion > 0 {
            taskCompletionTimer = Timer.scheduledTimer(withTimeInterval: timeUntilCompletion, repeats: false) { [weak self] _ in
                self?.handleTaskCompletion()
            }
        } else {
            // La tarea ya debería estar completada
            handleTaskCompletion()
        }
    }
    
    func handleTaskCompletion() {
        guard let task = activeTask, task.isCompleted else { return }
        completeTask(task)
        stopTask()
    }
    
    func completeTask(_ task: Task) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        var completedTask = tasks[taskIndex]
        completedTask.isActive = false
        
        // Verificar si hay check-ins pendientes y marcarlos como perdidos
        if let nextCheckIn = completedTask.nextCheckInTime,
           let deadline = completedTask.nextCheckInDeadline,
           Date() >= deadline {
            // Hay un check-in que se perdió
            var missedCheckIn = CheckIn(
                timestamp: nextCheckIn,
                photoData: nil,
                isVerified: false
            )
            missedCheckIn.verificationResult = .missed
            completedTask.checkIns.append(missedCheckIn)
        }
        
        // Verificar si la tarea se completó exitosamente
        let successRate = completedTask.completionRate
        let isSuccessful = successRate >= 0.7 // Al menos 70% de check-ins verificados
        
        // Asociar la tarea completada con la mascota que la hizo
        if let petId = completedTask.petId,
           let petIndex = pets.firstIndex(where: { $0.id == petId }) {
            // Agregar el ID de la tarea a la lista de tareas completadas de la mascota
            if !pets[petIndex].completedTaskIds.contains(completedTask.id) {
                pets[petIndex].completedTaskIds.append(completedTask.id)
            }
        }
        
        if isSuccessful {
            // Verificar que la mascota esté viva
            if let pet = currentPet, pet.isAlive {
                // Recompensar a la mascota por completar la tarea
                rewardPetForTaskCompletion()
                // Actualizar la racha solo si la mascota está viva
                updateStreak()
                
                // Actualizar días consecutivos de la mascota
                if let petIndex = pets.firstIndex(where: { $0.id == pet.id }) {
                    pets[petIndex].consecutiveDays += 1
                    currentPet = pets[petIndex]
                }
                
                // Verificar insignias de completación
                checkAllBadges()
            } else {
                // La mascota murió, no se actualiza la racha
                penalizePet()
            }
        } else {
            // Tarea no completada exitosamente
            penalizePet()
        }
        
        tasks[taskIndex] = completedTask
        saveData()
    }
    
    func startCheckInTimer() {
        checkInTimer?.invalidate()
        
        guard let task = activeTask, let nextCheckIn = task.nextCheckInTime else { return }
        
        let timeUntilCheckIn = nextCheckIn.timeIntervalSinceNow
        if timeUntilCheckIn > 0 {
            checkInTimer = Timer.scheduledTimer(withTimeInterval: timeUntilCheckIn, repeats: false) { [weak self] _ in
                self?.handleCheckInDue()
            }
        }
    }
    
    func handleCheckInDue() {
        // Notificar al usuario que es hora del check-in
        NotificationCenter.default.post(name: .checkInDue, object: nil)
        // Reiniciar el timer del deadline
        startCheckInDeadlineTimer()
    }
    
    func startCheckInDeadlineTimer() {
        checkInDeadlineTimer?.invalidate()
        
        guard let task = activeTask, let deadline = task.nextCheckInDeadline else { return }
        
        // Solo iniciar el timer si el check-in ya es debido
        guard task.isCheckInDue else { return }
        
        let timeUntilDeadline = deadline.timeIntervalSinceNow
        if timeUntilDeadline > 0 {
            checkInDeadlineTimer = Timer.scheduledTimer(withTimeInterval: timeUntilDeadline, repeats: false) { [weak self] _ in
                self?.handleCheckInMissed()
            }
        } else {
            // El deadline ya pasó
            handleCheckInMissed()
        }
    }
    
    func handleCheckInMissed() {
        guard let task = activeTask, task.isCheckInOverdue else { return }
        
        // Verificar si ya se completó el check-in
        let lastCheckIn = task.checkIns.last
        let lastCheckInTime = lastCheckIn?.timestamp ?? task.startTime ?? Date()
        
        // Si el último check-in fue antes del tiempo debido, se perdió
        if let nextCheckInTime = task.nextCheckInTime,
           lastCheckInTime < nextCheckInTime {
            // Marcar check-in como perdido
            markCheckInAsMissed()
        }
    }
    
    func markCheckInAsMissed() {
        guard let task = activeTask,
              let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        // Crear un check-in perdido
        var missedCheckIn = CheckIn(
            timestamp: task.nextCheckInTime ?? Date(),
            photoData: nil,
            isVerified: false
        )
        missedCheckIn.verificationResult = .missed
        
        tasks[taskIndex].checkIns.append(missedCheckIn)
        
        // Penalizar a la mascota por perder el check-in
        penalizePet()
        
        // Continuar con el siguiente check-in
        activeTask = tasks[taskIndex]
        startCheckInTimer()
        startCheckInDeadlineTimer()
        saveData()
        
        // Notificar que se perdió el check-in
        NotificationCenter.default.post(name: .checkInMissed, object: nil)
    }
    
    func performCheckIn(photoData: Data?) {
        guard let task = activeTask else { return }
        
        var checkIn = CheckIn(photoData: photoData)
        
        // Simular verificación de IA (en producción, esto sería una llamada real a la API)
        verifyCheckIn(checkIn: checkIn) { [weak self] verified in
            DispatchQueue.main.async {
                guard let self = self,
                      let taskIndex = self.tasks.firstIndex(where: { $0.id == task.id }) else {
                    return
                }
                
                // Agregar el check-in con el resultado de verificación
                checkIn.isVerified = verified
                checkIn.verificationResult = verified ? .verified : .failed
                self.tasks[taskIndex].checkIns.append(checkIn)
                
                if verified {
                    let oldLevel = self.currentPet?.level ?? 0
                    self.rewardPet()
                    
                    // Recompensar con monedas virtuales
                    self.virtualCurrency.coins += VirtualCurrency.rewardForCheckIn
                    
                    // Actualizar contadores
                    self.successfulCheckInsCount += 1
                    self.consecutiveSuccessfulCheckIns += 1
                    
                    // Verificar insignias
                    self.checkAllBadges()
                    
                    // Notificar cambios en tiempo real
                    if let newPet = self.currentPet, newPet.level != oldLevel {
                        NotificationCenter.default.post(name: .petLevelUp, object: nil)
                    }
                    NotificationCenter.default.post(name: .petStatsChanged, object: nil)
                    // No actualizar la racha aquí, solo cuando se complete la tarea
                } else {
                    self.penalizePet()
                    self.consecutiveSuccessfulCheckIns = 0
                }
                
                self.activeTask = self.tasks[taskIndex]
                self.startCheckInTimer()
                self.startCheckInDeadlineTimer()
                self.saveData()
            }
        }
    }
    
    private func verifyCheckIn(checkIn: CheckIn, completion: @escaping (Bool) -> Void) {
        // Simulación de verificación de IA
        // En producción, aquí se enviaría la foto a un servicio de IA
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Simular 90% de éxito
            completion(Double.random(in: 0...1) < 0.9)
        }
    }
    
    func rewardPet() {
        guard let petIndex = pets.firstIndex(where: { $0.id == currentPet?.id }) else { return }
        
        // Calcular experiencia base
        var experienceGained = Pet.baseExperience
        
        // Multiplicador por racha
        // Racha 0-6 días: x1.0
        // Racha 7-13 días: x1.5
        // Racha 14-29 días: x2.0
        // Racha 30+ días: x2.5
        let streakMultiplier: Double
        if streak.currentStreak >= 30 {
            streakMultiplier = 2.5
        } else if streak.currentStreak >= 14 {
            streakMultiplier = 2.0
        } else if streak.currentStreak >= 7 {
            streakMultiplier = 1.5
        } else {
            streakMultiplier = 1.0
        }
        
        experienceGained = Int(Double(experienceGained) * streakMultiplier)
        
        let oldLevel = pets[petIndex].level
        let oldHealth = pets[petIndex].health
        let oldHappiness = pets[petIndex].happiness
        
        // Aplicar recompensa
        pets[petIndex].reward(experienceGained: experienceGained)
        pets[petIndex].feed()
        currentPet = pets[petIndex]
        
        // Notificar cambios en tiempo real
        if pets[petIndex].level != oldLevel {
            NotificationCenter.default.post(name: .petLevelUp, object: nil)
        }
        if pets[petIndex].health != oldHealth || pets[petIndex].happiness != oldHappiness {
            NotificationCenter.default.post(name: .petStatsChanged, object: nil)
        }
        
        saveData()
    }
    
    func rewardPetForTaskCompletion() {
        guard let petIndex = pets.firstIndex(where: { $0.id == currentPet?.id }) else { return }
        
        let oldLevel = pets[petIndex].level
        let oldHealth = pets[petIndex].health
        let oldHappiness = pets[petIndex].happiness
        
        // Experiencia adicional por completar tarea (con multiplicador de racha)
        var taskCompletionExp = 20
        
        // Aplicar multiplicador de racha también a la experiencia de completar tarea
        let streakMultiplier: Double
        if streak.currentStreak >= 30 {
            streakMultiplier = 2.5
        } else if streak.currentStreak >= 14 {
            streakMultiplier = 2.0
        } else if streak.currentStreak >= 7 {
            streakMultiplier = 1.5
        } else {
            streakMultiplier = 1.0
        }
        
        taskCompletionExp = Int(Double(taskCompletionExp) * streakMultiplier)
        
        pets[petIndex].reward(experienceGained: taskCompletionExp)
        pets[petIndex].feed()
        currentPet = pets[petIndex]
        
        // Recompensar con monedas virtuales por completar tarea
        virtualCurrency.coins += VirtualCurrency.rewardForTaskCompletion
        
        // Notificar cambios en tiempo real
        if pets[petIndex].level != oldLevel {
            NotificationCenter.default.post(name: .petLevelUp, object: nil)
        }
        if pets[petIndex].health != oldHealth || pets[petIndex].happiness != oldHappiness {
            NotificationCenter.default.post(name: .petStatsChanged, object: nil)
        }
        
        saveData()
    }
    
    func penalizePet() {
        guard let petIndex = pets.firstIndex(where: { $0.id == currentPet?.id }) else { return }
        
        let oldHealth = pets[petIndex].health
        let oldHappiness = pets[petIndex].happiness
        
        pets[petIndex].neglect()
        currentPet = pets[petIndex]
        
        // Notificar cambios en tiempo real
        if pets[petIndex].health != oldHealth || pets[petIndex].happiness != oldHappiness {
            NotificationCenter.default.post(name: .petStatsChanged, object: nil)
        }
        
        // Notificar si la mascota murió
        if !pets[petIndex].isAlive && pets[petIndex].deathDate == nil {
            // Marcar la fecha de muerte
            pets[petIndex].deathDate = Date()
            NotificationCenter.default.post(name: .petDied, object: nil)
        }
        
        saveData()
    }
    
    // Monitoreo continuo de la salud de la mascota
    func startPetHealthMonitor() {
        petHealthMonitorTimer?.invalidate()
        
        // Verificar una vez al día si hay deterioro (cada 24 horas)
        // Calcular tiempo hasta la próxima medianoche
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        let timeUntilMidnight = tomorrow.timeIntervalSince(now)
        
        // Primera verificación al llegar a medianoche
        petHealthMonitorTimer = Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { [weak self] _ in
            self?.checkPetHealth()
            // Después de la primera verificación, verificar cada 24 horas
            self?.petHealthMonitorTimer = Timer.scheduledTimer(withTimeInterval: 24 * 3600, repeats: true) { [weak self] _ in
                self?.checkPetHealth()
            }
        }
        
        // También verificar inmediatamente al iniciar (por si ya pasó un día)
        checkPetHealth()
    }
    
    func checkPetHealth() {
        guard let pet = currentPet, pet.isAlive else { return }
        
        // Si hay una tarea activa, verificar si hay check-ins perdidos
        if let task = activeTask {
            // Verificar si hay un check-in que se perdió pero no se registró
            if task.isCheckInOverdue {
                let lastCheckIn = task.checkIns.last
                let lastCheckInTime = lastCheckIn?.timestamp ?? task.startTime ?? Date()
                
                if let nextCheckInTime = task.nextCheckInTime,
                   lastCheckInTime < nextCheckInTime,
                   lastCheckIn?.verificationResult != .missed {
                    // Hay un check-in perdido que no se registró
                    markCheckInAsMissed()
                }
            }
        } else {
            // Si no hay tarea activa, verificar deterioro diario
            // Los días que no se abre la app TAMBIÉN cuentan (la mascota está viva)
            if let lastFed = pet.lastFed {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let lastFedDay = calendar.startOfDay(for: lastFed)
                let daysSinceFed = calendar.dateComponents([.day], from: lastFedDay, to: today).day ?? 0
                
                // Calcular desde cuándo se debe empezar a contar el deterioro
                // Día 1-2: Sin deterioro (tiempo de gracia)
                // Día 3+: Comienza el deterioro
                let daysToDeteriorate = max(0, daysSinceFed - 2) // Días que deben contar para deterioro
                
                if daysToDeteriorate > 0 {
                    // Calcular cuántos días de deterioro se deben aplicar
                    // Si hay lastDeteriorationDate, calcular desde ahí
                    // Si no hay, significa que nunca se aplicó deterioro, aplicar todos los días pendientes
                    let daysToApply: Int
                    
                    if let lastDeterioration = pet.lastDeteriorationDate {
                        let lastDeteriorationDay = calendar.startOfDay(for: lastDeterioration)
                        let daysSinceLastDeterioration = calendar.dateComponents([.day], from: lastDeteriorationDay, to: today).day ?? 0
                        // Aplicar deterioro por cada día que pasó desde la última vez
                        daysToApply = daysSinceLastDeterioration
                    } else {
                        // Nunca se aplicó deterioro, aplicar todos los días pendientes
                        daysToApply = daysToDeteriorate
                    }
                    
                    if daysToApply > 0, let petIndex = pets.firstIndex(where: { $0.id == pet.id }) {
                        // Aplicar deterioro acumulado de todos los días que pasaron
                        gradualPetDeterioration(petIndex: petIndex, days: daysToApply)
                        pets[petIndex].lastDeteriorationDate = Date()
                        currentPet = pets[petIndex]
                        saveData()
                    }
                }
            } else {
                // Si nunca ha sido alimentada, alimentarla automáticamente
                // para dar tiempo de gracia antes de que empiece a deteriorarse
                if let petIndex = pets.firstIndex(where: { $0.id == pet.id }) {
                    pets[petIndex].feed()
                    currentPet = pets[petIndex]
                    saveData()
                }
            }
        }
    }
    
    func gradualPetDeterioration(petIndex: Int, days: Int = 1) {
        guard petIndex < pets.count, pets[petIndex].isAlive else { return }
        
        // Deterioro diario balanceado:
        // - 3 puntos de salud por día
        // - 2 puntos de felicidad por día
        // Aplicar el deterioro acumulado de todos los días que pasaron
        let healthReduction = 3 * days
        let happinessReduction = 2 * days
        
        pets[petIndex].health = max(0, pets[petIndex].health - healthReduction)
        pets[petIndex].happiness = max(0, pets[petIndex].happiness - happinessReduction)
        
        if !pets[petIndex].isAlive && pets[petIndex].deathDate == nil {
            // Marcar la fecha de muerte
            pets[petIndex].deathDate = Date()
            NotificationCenter.default.post(name: .petDied, object: nil)
        }
        
        // Notificar cambios en tiempo real
        NotificationCenter.default.post(name: .petStatsChanged, object: nil)
    }
    
    func updateStreak() {
        streak.updateStreak()
        checkBadgeUnlocks()
        saveData()
    }
    
    func checkBadgeUnlocks() {
        let milestone = streak.milestone
        if milestone != .none {
            unlockBadge(for: milestone)
        }
    }
    
    func unlockBadge(for milestone: StreakMilestone) {
        if let index = badges.firstIndex(where: { $0.name == milestone.name && !$0.isUnlocked }) {
            badges[index].isUnlocked = true
            badges[index].unlockedDate = Date()
            totalPoints += badges[index].points
            
            // Recompensar con monedas por desbloquear insignia
            virtualCurrency.coins += VirtualCurrency.rewardForBadge
            
            NotificationCenter.default.post(name: .badgeUnlocked, object: badges[index])
            saveData()
        }
    }
    
    func checkAllBadges() {
        // Verificar insignias de completación
        let completedCount = tasks.filter { !$0.isActive && $0.completionRate >= 0.7 }.count
        completedTasksCount = completedCount
        
        unlockBadgeIfCondition("Primer Paso", condition: completedCount >= 1)
        unlockBadgeIfCondition("Aprendiz", condition: completedCount >= 5)
        unlockBadgeIfCondition("Estudiante", condition: completedCount >= 10)
        unlockBadgeIfCondition("Experto", condition: completedCount >= 25)
        unlockBadgeIfCondition("Maestro", condition: completedCount >= 50)
        unlockBadgeIfCondition("Leyenda", condition: completedCount >= 100)
        
        // Verificar insignias de consistencia
        let totalCheckIns = tasks.flatMap { $0.checkIns }.filter { $0.isVerified }.count
        successfulCheckInsCount = totalCheckIns
        
        unlockBadgeIfCondition("Puntual", condition: totalCheckIns >= 10)
        unlockBadgeIfCondition("Precisión", condition: totalCheckIns >= 25)
        unlockBadgeIfCondition("Perfecto", condition: totalCheckIns >= 50)
        unlockBadgeIfCondition("Sin Errores", condition: totalCheckIns >= 100)
        unlockBadgeIfCondition("Maestro del Tiempo", condition: totalCheckIns >= 100)
        
        // Verificar check-ins consecutivos
        unlockBadgeIfCondition("Ritmo Constante", condition: consecutiveSuccessfulCheckIns >= 10)
        unlockBadgeIfCondition("Máxima Eficiencia", condition: consecutiveSuccessfulCheckIns >= 25)
        
        // Verificar tareas sin errores
        let perfectTasks = tasks.filter { task in
            !task.isActive && task.completionRate >= 1.0
        }.count
        unlockBadgeIfCondition("Sobreviviente", condition: perfectTasks >= 1)
        unlockBadgeIfCondition("Invencible", condition: perfectTasks >= 10)
        
        // Verificar tareas largas
        let longTasks = tasks.filter { $0.duration >= 8 * 3600 && !$0.isActive && $0.completionRate >= 0.7 }.count
        unlockBadgeIfCondition("Dedicación Total", condition: longTasks >= 1)
        
        // Verificar tareas en un día
        checkDailyTasksBadge()
        
        // Verificar mascotas
        checkPetBadges()
    }
    
    func unlockBadgeIfCondition(_ badgeName: String, condition: Bool) {
        if condition, let index = badges.firstIndex(where: { $0.name == badgeName && !$0.isUnlocked }) {
            badges[index].isUnlocked = true
            badges[index].unlockedDate = Date()
            totalPoints += badges[index].points
            
            // Recompensar con monedas por desbloquear insignia
            virtualCurrency.coins += VirtualCurrency.rewardForBadge
            
            NotificationCenter.default.post(name: .badgeUnlocked, object: badges[index])
            saveData()
        }
    }
    
    func checkDailyTasksBadge() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayTasks = tasks.filter { task in
            guard let startTime = task.startTime else { return false }
            let taskDay = calendar.startOfDay(for: startTime)
            return taskDay == today && !task.isActive && task.completionRate >= 0.7
        }.count
        unlockBadgeIfCondition("Velocidad", condition: todayTasks >= 5)
    }
    
    func checkPetBadges() {
        // Verificar nivel máximo de mascota
        if let pet = currentPet, pet.level >= Pet.maxLevel {
            unlockBadgeIfCondition("Maestro de Mascotas", condition: true)
        }
        
        // Verificar mascotas desbloqueadas
        let uniqueTypes = Set(pets.map { $0.type }).count
        unlockBadgeIfCondition("Coleccionista", condition: uniqueTypes >= 5)
    }
    
    func addPet(_ pet: Pet) {
        // Si es gratis (gato) y ya tiene mascota, no permitir
        if pet.type.price == 0.0 && pets.count >= 1 {
            return
        }
        
        // Si es gratis y no tiene mascotas, permitir
        if pet.type.price == 0.0 && pets.count == 0 {
            pets.append(pet)
            if currentPet == nil {
                currentPet = pet
            }
            saveData()
            return
        }
        
        // Si tiene precio, es una compra, permitir siempre (sin límite de cantidad)
        if pet.type.price > 0.0 {
            pets.append(pet)
            if currentPet == nil {
                currentPet = pet
            }
            saveData()
            return
        }
        
        // Para otros casos, verificar límite normal
        if pets.count < settings.maxPets {
            pets.append(pet)
            if currentPet == nil {
                currentPet = pet
            }
            saveData()
        }
    }
    
    func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        if currentPet?.id == pet.id {
            currentPet = pets.first
        }
        saveData()
    }
    
    func upgradeToPremium() {
        settings.isPremium = true
        settings.maxPets = 10
        saveData()
    }
    
    // MARK: - Helper Functions
    
    // Obtener mascotas muertas
    var deadPets: [Pet] {
        pets.filter { !$0.isAlive }
    }
    
    // Obtener tareas completadas de una mascota
    func completedTasks(for pet: Pet) -> [Task] {
        tasks.filter { pet.completedTaskIds.contains($0.id) }
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        dataManager.save(tasks: tasks, pets: pets, streak: streak, badges: badges, settings: settings, currentPetId: currentPet?.id, virtualCurrency: virtualCurrency, totalPoints: totalPoints, completedTasksCount: completedTasksCount, successfulCheckInsCount: successfulCheckInsCount, consecutiveSuccessfulCheckIns: consecutiveSuccessfulCheckIns)
    }
    
    func loadData() {
        isLoadingData = true // Marcar que estamos cargando datos
        
        if let data = dataManager.load() {
            tasks = data.tasks
            pets = data.pets
            streak = data.streak
            badges = data.badges
            settings = data.settings
            virtualCurrency = data.virtualCurrency ?? VirtualCurrency()
            totalPoints = data.totalPoints
            completedTasksCount = data.completedTasksCount
            successfulCheckInsCount = data.successfulCheckInsCount
            consecutiveSuccessfulCheckIns = data.consecutiveSuccessfulCheckIns
            
            activeTask = tasks.first { $0.isActive }
            
            // Restaurar la mascota activa
            if let currentPetId = data.currentPetId,
               let savedPet = pets.first(where: { $0.id == currentPetId }) {
                currentPet = savedPet
            }
        }
        
        isLoadingData = false // Marcar que terminamos de cargar
    }
    
    // Procesar tarea activa cuando la app se reabre
    func processActiveTaskOnAppLaunch() {
        guard let task = activeTask, let startTime = task.startTime, let endTime = task.endTime else {
            return
        }
        
        let now = Date()
        
        // Verificar si la tarea ya terminó
        if now >= endTime {
            // La tarea se completó mientras la app estaba cerrada
            processMissedCheckInsForCompletedTask(task)
            completeTask(task)
            stopTask()
            return
        }
        
        // Procesar check-ins perdidos que ocurrieron mientras la app estaba cerrada
        processMissedCheckInsWhileAppWasClosed(task, currentTime: now)
        
        // Reiniciar timers para continuar con la tarea
        startCheckInTimer()
        startCheckInDeadlineTimer()
        startTaskCompletionTimer()
        
        // Re-programar notificaciones para los check-ins restantes
        notificationManager.scheduleCheckInNotifications(for: task)
    }
    
    // Procesar check-ins perdidos mientras la app estaba cerrada
    private func processMissedCheckInsWhileAppWasClosed(_ task: Task, currentTime: Date) {
        guard let startTime = task.startTime else { return }
        
        let checkInInterval = task.checkInInterval
        let lastCheckInTime = task.checkIns.last?.timestamp ?? startTime
        let nextExpectedCheckIn = lastCheckInTime.addingTimeInterval(checkInInterval)
        
        // Calcular la ventana de tiempo
        let windowPercentage = 0.2
        var windowTime = checkInInterval * windowPercentage
        let minWindow: TimeInterval = 2 * 60
        let maxWindow: TimeInterval = 10 * 60
        windowTime = max(minWindow, min(windowTime, maxWindow))
        
        // Procesar todos los check-ins que deberían haber ocurrido
        var checkInTime = nextExpectedCheckIn
        var checkInNumber = (task.checkIns.count) + 1
        
        while checkInTime <= currentTime {
            let deadline = checkInTime.addingTimeInterval(windowTime)
            
            // Si ya pasó el deadline, marcar como perdido
            if currentTime >= deadline {
                var missedCheckIn = CheckIn(
                    timestamp: checkInTime,
                    photoData: nil,
                    isVerified: false
                )
                missedCheckIn.verificationResult = .missed
                
                if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[taskIndex].checkIns.append(missedCheckIn)
                    
                    // Penalizar a la mascota por cada check-in perdido
                    if let petId = tasks[taskIndex].petId,
                       let petIndex = pets.firstIndex(where: { $0.id == petId }) {
                        penalizePetForMissedCheckIn(petIndex: petIndex)
                    }
                }
            }
            
            // Calcular el siguiente check-in
            checkInTime = checkInTime.addingTimeInterval(checkInInterval)
            checkInNumber += 1
        }
        
        // Actualizar la tarea activa
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            activeTask = tasks[taskIndex]
            saveData()
        }
    }
    
    // Procesar check-ins perdidos para una tarea que ya se completó
    private func processMissedCheckInsForCompletedTask(_ task: Task) {
        guard let startTime = task.startTime, let endTime = task.endTime else { return }
        
        let checkInInterval = task.checkInInterval
        let lastCheckInTime = task.checkIns.last?.timestamp ?? startTime
        let nextExpectedCheckIn = lastCheckInTime.addingTimeInterval(checkInInterval)
        
        // Calcular la ventana de tiempo
        let windowPercentage = 0.2
        var windowTime = checkInInterval * windowPercentage
        let minWindow: TimeInterval = 2 * 60
        let maxWindow: TimeInterval = 10 * 60
        windowTime = max(minWindow, min(windowTime, maxWindow))
        
        // Procesar todos los check-ins que deberían haber ocurrido antes del fin
        var checkInTime = nextExpectedCheckIn
        
        while checkInTime <= endTime {
            let deadline = checkInTime.addingTimeInterval(windowTime)
            
            // Si el deadline pasó antes del fin de la tarea, marcar como perdido
            if deadline <= endTime {
                var missedCheckIn = CheckIn(
                    timestamp: checkInTime,
                    photoData: nil,
                    isVerified: false
                )
                missedCheckIn.verificationResult = .missed
                
                if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[taskIndex].checkIns.append(missedCheckIn)
                    
                    // Penalizar a la mascota por cada check-in perdido
                    if let petId = tasks[taskIndex].petId,
                       let petIndex = pets.firstIndex(where: { $0.id == petId }) {
                        penalizePetForMissedCheckIn(petIndex: petIndex)
                    }
                }
            }
            
            checkInTime = checkInTime.addingTimeInterval(checkInInterval)
        }
        
        // Actualizar la tarea activa después de procesar todos los check-ins perdidos
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            activeTask = tasks[taskIndex]
        }
    }
    
    // Penalizar a la mascota por un check-in perdido
    private func penalizePetForMissedCheckIn(petIndex: Int) {
        guard petIndex < pets.count else { return }
        
        let oldHealth = pets[petIndex].health
        let oldHappiness = pets[petIndex].happiness
        
        pets[petIndex].neglect()
        
        if let currentPetId = currentPet?.id, pets[petIndex].id == currentPetId {
            currentPet = pets[petIndex]
        }
        
        // Notificar cambios
        if pets[petIndex].health != oldHealth || pets[petIndex].happiness != oldHappiness {
            NotificationCenter.default.post(name: .petStatsChanged, object: nil)
        }
        
        // Verificar si la mascota murió
        if !pets[petIndex].isAlive && pets[petIndex].deathDate == nil {
            pets[petIndex].deathDate = Date()
            NotificationCenter.default.post(name: .petDied, object: nil)
        }
    }
}

extension Notification.Name {
    static let checkInDue = Notification.Name("checkInDue")
    static let checkInMissed = Notification.Name("checkInMissed")
    static let petDied = Notification.Name("petDied")
    static let taskCancelled = Notification.Name("taskCancelled")
    static let petLevelUp = Notification.Name("petLevelUp")
    static let petStatsChanged = Notification.Name("petStatsChanged")
    static let badgeUnlocked = Notification.Name("badgeUnlocked")
    static let updateCheckInTimer = Notification.Name("updateCheckInTimer")
}

