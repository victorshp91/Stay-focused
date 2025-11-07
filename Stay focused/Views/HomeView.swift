//
//  HomeView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingTaskSetup = false
    @State private var showingCheckIn = false
    @State private var showRules = false
    @State private var unlockedBadge: Badge?
    @State private var showBadgeAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                GameColorTheme.homeBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                    // Tarea Activa
                    if let activeTask = viewModel.activeTask {
                        ActiveTaskCard(
                            task: activeTask,
                            currentPet: viewModel.currentPet,
                            onCheckIn: {
                                showingCheckIn = true
                            },
                            onCancel: {
                                viewModel.cancelTask()
                            }
                        )
                    } else {
                        NoActiveTaskCard {
                            showingTaskSetup = true
                        }
                    }
                    
                    // Resumen Rápido con estilo de juego
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            QuickStatCard(
                                icon: "flame.fill",
                                value: "\(viewModel.streak.currentStreak)",
                                label: "Días",
                                color: .orange
                            )
                            
                            QuickStatCard(
                                icon: "trophy.fill",
                                value: "\(viewModel.badges.filter { $0.isUnlocked }.count)",
                                label: "Insignias",
                                color: .purple
                            )
                            
                            QuickStatCard(
                                icon: "pawprint.fill",
                                value: "\(viewModel.pets.count)",
                                label: "Mascotas",
                                color: .blue
                            )
                        }
                        
                        // Puntos totales
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(viewModel.totalPoints)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                Text("Puntos Totales")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // Mascota Actual (Preview) - Estilo de juego
                    if let pet = viewModel.currentPet {
                        VStack(spacing: 12) {
                            // Badge de Mascota Activa
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                                Text("Mascota Activa")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.green.opacity(0.2),
                                                Color.green.opacity(0.1)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .padding(.horizontal)
                            
                            GameStylePetPreviewCard(pet: pet)
                                .padding(.horizontal)
                            
                            // Información sobre la mascota activa
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("Esta mascota recibe todas las recompensas y penalizaciones")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                    }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Stay Focused")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showRules = true }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingTaskSetup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showRules) {
                RulesView()
            }
            .sheet(isPresented: $showingTaskSetup) {
                TaskSetupView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingCheckIn) {
                CheckInView()
                    .environmentObject(viewModel)
            }
            .onReceive(NotificationCenter.default.publisher(for: .checkInDue)) { _ in
                // Abrir automáticamente el sheet de check-in cuando es hora
                // Solo si hay una tarea activa y el check-in está debido
                if let task = viewModel.activeTask, task.isCheckInDue {
                    DispatchQueue.main.async {
                        showingCheckIn = true
                    }
                }
            }
            .onAppear {
                // Verificar si hay un check-in debido cuando la vista aparece
                if let task = viewModel.activeTask, task.isCheckInDue, !showingCheckIn {
                    // Pequeño delay para asegurar que la vista esté completamente cargada
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingCheckIn = true
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .checkInMissed)) { _ in
                // Mostrar alerta cuando se pierde un check-in
            }
            .onReceive(NotificationCenter.default.publisher(for: .petDied)) { _ in
                // Notificar que la mascota murió
            }
            .onReceive(NotificationCenter.default.publisher(for: .badgeUnlocked)) { notification in
                if let badge = notification.object as? Badge {
                    unlockedBadge = badge
                    showBadgeAnimation = true
                }
            }
            .sheet(isPresented: $showBadgeAnimation) {
                if let badge = unlockedBadge {
                    BadgeUnlockAnimationView(badge: badge, isPresented: $showBadgeAnimation)
                }
            }
        }
    }
}

struct ActiveTaskCard: View {
    let task: Task
    let currentPet: Pet?
    let onCheckIn: () -> Void
    let onCancel: () -> Void
    @State private var showingCancelConfirmation = false
    @State private var pulseAnimation = false
    
    func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    func calculateWindowTime(for task: Task) -> TimeInterval {
        let windowPercentage = 0.2 // 20%
        var windowTime = task.checkInInterval * windowPercentage
        
        // Aplicar límites: mínimo 2 minutos, máximo 10 minutos
        let minWindow: TimeInterval = 2 * 60 // 2 minutos
        let maxWindow: TimeInterval = 10 * 60 // 10 minutos
        
        windowTime = max(minWindow, min(windowTime, maxWindow))
        return windowTime
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Tarea Activa")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                HStack(spacing: 10) {
                    Button(action: onCheckIn) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                    
                    Button(action: {
                        showingCancelConfirmation = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.red, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            
            // Barra de Progreso
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(task.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                ProgressView(value: task.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .animation(.spring(response: 0.3), value: task.progress)
            }
            
                    if let endTime = task.endTime {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.secondary)
                            Text("Termina: \(endTime, style: .relative)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Información sobre la racha
                    if currentPet != nil {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("La racha aumenta al completar la tarea si tu mascota está viva")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 5)
                    }
            
            if task.isCheckInDue {
                VStack(spacing: 10) {
                    Button(action: onCheckIn) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text("Check-in Requerido")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(task.isCheckInOverdue ? Color.red : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if let timeRemaining = task.timeRemainingForCheckIn, timeRemaining > 0 {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("Tiempo restante: \(formatTimeRemaining(timeRemaining))")
                                    .font(.caption)
                            }
                            .foregroundColor(task.isCheckInOverdue ? .red : .orange)
                            
                            // Mostrar información de la ventana
                            let windowTime = calculateWindowTime(for: task)
                            Text("Ventana: \(formatTimeRemaining(windowTime))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else if task.isCheckInOverdue {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Check-in perdido - Se aplicará penalización")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.7, blue: 1.0).opacity(0.3),
                            Color(red: 0.7, green: 0.6, blue: 1.0).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.4), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .padding(.horizontal)
        .alert("Cancelar Tarea", isPresented: $showingCancelConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Sí, Cancelar", role: .destructive) {
                onCancel()
            }
        } message: {
            Text("¿Estás seguro de que quieres cancelar esta tarea? Tu mascota será penalizada por abandonar la tarea.")
        }
    }
}

struct NoActiveTaskCard: View {
    let onCreateTask: () -> Void
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .scaleEffect(animateIcon ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
            
            Text("No hay tarea activa")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Crea una nueva tarea para comenzar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateTask) {
                Text("Crear Tarea")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .gray.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal)
        .onAppear {
            animateIcon = true
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animate)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            color.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    color.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    animate = true
                }
            }
        }
    }
}

struct GameStylePetPreviewCard: View {
    let pet: Pet
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradiente de fondo
            ZStack {
                LinearGradient(
                    colors: getHealthGradient(pet.health),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Badge de Activa en la esquina
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("ACTIVA")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.9), Color.green.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.5), radius: 5, x: 0, y: 2)
                        )
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    }
                    Spacer()
                }
                
                // Mascota
                VStack(spacing: 15) {
                    Text(pet.type.emoji)
                        .font(.system(size: 80))
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true), value: animate)
                    
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    // Nivel
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Nivel \(pet.level)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .blur(radius: 10)
                            )
                    )
                }
                .padding(.vertical, 20)
            }
            .frame(height: 200)
            
            // Stats
            HStack(spacing: 0) {
                // Salud
                StatBar(
                    icon: "heart.fill",
                    value: pet.health,
                    color: .red,
                    label: "Salud"
                )
                
                Divider()
                    .frame(height: 40)
                
                // Felicidad
                StatBar(
                    icon: "star.fill",
                    value: pet.happiness,
                    color: .yellow,
                    label: "Felicidad"
                )
                
                Divider()
                    .frame(height: 40)
                
                // Experiencia
                StatBar(
                    icon: "sparkle.fill",
                    value: pet.experience,
                    total: pet.experienceRequired,
                    color: .blue,
                    label: "XP"
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.white)
        }
        .cornerRadius(25)
        .shadow(color: getHealthGradient(pet.health)[0].opacity(0.4), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .onAppear {
            animate = true
        }
    }
    
    private func getHealthGradient(_ health: Int) -> [Color] {
        if health >= 80 {
            return [Color.green.opacity(0.8), Color.green.opacity(0.4)]
        } else if health >= 50 {
            return [Color.yellow.opacity(0.8), Color.yellow.opacity(0.4)]
        } else if health >= 20 {
            return [Color.orange.opacity(0.8), Color.orange.opacity(0.4)]
        } else {
            return [Color.red.opacity(0.8), Color.red.opacity(0.4)]
        }
    }
}

struct StatBar: View {
    let icon: String
    let value: Int
    var total: Int? = nil
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                if let total = total {
                    Text("\(value)/\(total)")
                        .font(.caption)
                        .fontWeight(.bold)
                } else {
                    Text("\(value)%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PetPreviewCard: View {
    let pet: Pet
    
    var body: some View {
        GameStylePetPreviewCard(pet: pet)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}

