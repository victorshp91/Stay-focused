//
//  PetStatusView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct PetStatusView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingPetSelection = false
    @State private var showingCemetery = false
    @State private var showingTaskHistory = false
    @State private var refreshTimer: Timer?
    @State private var timerShouldRun = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                GameColorTheme.petBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                    if let pet = viewModel.currentPet {
                        // Badge de Mascota Activa
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.green.opacity(0.4),
                                                Color.green.opacity(0.2),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 30
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                    .blur(radius: 10)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mascota Activa")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Recibe todas las recompensas y penalizaciones")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.15),
                                            Color.green.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.5),
                                            Color.green.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                        
                        // Mascota Principal con diseño de juego
                        VStack(spacing: 15) {
                            ZStack {
                                // Glow effect para mascota viva
                                if pet.isAlive {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    getHealthGlowColor(pet.health).opacity(0.4),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 30,
                                                endRadius: 80
                                            )
                                        )
                                        .frame(width: 150, height: 150)
                                        .blur(radius: 20)
                                }
                                
                                Text(pet.type.emoji)
                                    .font(.system(size: 100))
                                    .scaleEffect(pet.isAlive ? 1.0 : 0.8)
                                    .opacity(pet.isAlive ? 1.0 : 0.6)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: pet.health)
                            }
                            
                            VStack(spacing: 5) {
                                Text(pet.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 8) {
                                    Text("Nivel \(pet.level)")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue.opacity(0.2))
                                        )
                                    
                                    if pet.level >= Pet.maxLevel {
                                        HStack(spacing: 4) {
                                            Image(systemName: "crown.fill")
                                                .foregroundColor(.yellow)
                                            Text("MAX")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.yellow)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                    }
                                }
                            }
                            
                            // Barra de Experiencia
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Experiencia")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if pet.level >= Pet.maxLevel {
                                        Text("Nivel Máximo")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                if pet.level < Pet.maxLevel {
                                    ProgressView(value: Double(pet.experience), total: Double(pet.experienceRequired))
                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        .animation(.spring(response: 0.3), value: pet.experience)
                                    
                                    Text("\(pet.experience) / \(pet.experienceRequired) XP")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .contentTransition(.numericText())
                                    
                                    // Mostrar multiplicador de racha si aplica
                                    let currentStreak = viewModel.streak.currentStreak
                                    if currentStreak >= 7 {
                                        let multiplier = currentStreak >= 30 ? "2.5x" : currentStreak >= 14 ? "2.0x" : "1.5x"
                                        HStack {
                                            Image(systemName: "flame.fill")
                                                .foregroundColor(.orange)
                                            Text("Multiplicador de racha: \(multiplier)")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.top, 2)
                                    }
                                } else {
                                    Text("¡Has alcanzado el nivel máximo!")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Estado de Salud
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Salud")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(pet.health)%")
                                        .fontWeight(.semibold)
                                        .foregroundColor(healthColor(pet.health))
                                }
                                ProgressView(value: Double(pet.health), total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: healthColor(pet.health)))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                    .animation(.spring(response: 0.3), value: pet.health)
                                
                                HStack {
                                    Label("Felicidad", systemImage: "star.fill")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(pet.happiness)%")
                                        .fontWeight(.semibold)
                                        .foregroundColor(happinessColor(pet.happiness))
                                        .contentTransition(.numericText())
                                }
                                ProgressView(value: Double(pet.happiness), total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: happinessColor(pet.happiness)))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                    .animation(.spring(response: 0.3), value: pet.happiness)
                                
                                Text("⭐ La felicidad aumenta cuando completas tareas exitosamente")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            // Estado
                            HStack {
                                Label(pet.healthStatus.rawValue, systemImage: healthIcon(pet.healthStatus))
                                    .foregroundColor(healthColor(pet.health))
                            }
                            .padding()
                            .background(healthColor(pet.health).opacity(0.2))
                            .cornerRadius(10)
                            
                            if !pet.isAlive {
                                VStack(spacing: 15) {
                                    Text("💀")
                                        .font(.system(size: 60))
                                    
                                    Text("Tu mascota ha fallecido")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    
                                    Text("Por falta de cuidado y check-ins perdidos")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        // Crear una nueva mascota
                                        let newPet = Pet(name: "Nueva Mascota", type: .cat)
                                        viewModel.addPet(newPet)
                                        viewModel.currentPet = newPet
                                    }) {
                                        Text("Crear Nueva Mascota")
                                            .fontWeight(.semibold)
                                            .padding()
                                            .frame(maxWidth: .infinity)
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
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.red.opacity(0.15), Color.red.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                            }
                            
                            // Días Consecutivos
                            if pet.consecutiveDays > 0 {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("\(pet.consecutiveDays) días consecutivos")
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Botones de acción
                            HStack(spacing: 15) {
                                // Botón para ver historial de tareas
                                Button(action: {
                                    showingTaskHistory = true
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet.rectangle")
                                        Text("Historial")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.4, blue: 1.0),
                                                Color(red: 0.4, green: 0.6, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                
                                // Botón para ver cementerio (siempre visible)
                                Button(action: {
                                    showingCemetery = true
                                }) {
                                    HStack {
                                        Image(systemName: "tombstone.fill")
                                        Text("Cementerio")
                                        if !viewModel.deadPets.isEmpty {
                                            Text("(\(viewModel.deadPets.count))")
                                                .font(.caption)
                                                .opacity(0.8)
                                        }
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.3, blue: 0.35),
                                                Color(red: 0.2, green: 0.2, blue: 0.25)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding(.top, 10)
                        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.gray.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal)
                        
                        // Lista de Mascotas
                        if viewModel.pets.count > 1 {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Mis Mascotas")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    if viewModel.activeTask != nil {
                                        Text("Tarea activa")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    } else {
                                        Text("Toca para cambiar")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(viewModel.pets) { pet in
                                            PetCard(
                                                pet: pet,
                                                isSelected: pet.id == viewModel.currentPet?.id,
                                                isActive: pet.id == viewModel.currentPet?.id
                                            ) {
                                                // No permitir cambiar mascota si hay una tarea activa
                                                if viewModel.activeTask != nil {
                                                    return
                                                }
                                                viewModel.currentPet = pet
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Información sobre restricciones y mascotas inactivas
                                VStack(spacing: 8) {
                                    if viewModel.activeTask != nil {
                                        HStack(spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                            Text("No puedes cambiar de mascota mientras hay una tarea activa")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.red.opacity(0.1))
                                        )
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("Las mascotas inactivas no se deterioran ni reciben efectos")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.orange.opacity(0.1))
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        Text("No tienes mascotas")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Mi Mascota")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPetSelection = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingPetSelection) {
                NavigationView {
                    PetSelectionView()
                        .environmentObject(viewModel)
                }
                .interactiveDismissDisabled(false)
            }
            .sheet(isPresented: $showingCemetery) {
                CemeteryView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingTaskHistory) {
                if let pet = viewModel.currentPet {
                    PetTasksHistoryView(pet: pet)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                // Iniciar timer solo si no hay sheet abierto
                startRefreshTimer()
            }
            .onDisappear {
                // Detener timer cuando la vista desaparece
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
            .onChange(of: showingPetSelection) { isShowing in
                if isShowing {
                    // Detener timer cuando se abre el sheet
                    timerShouldRun = false
                    refreshTimer?.invalidate()
                    refreshTimer = nil
                } else {
                    // Reiniciar timer cuando se cierra el sheet
                    timerShouldRun = true
                    startRefreshTimer()
                }
            }
            .onChange(of: showingTaskHistory) { isShowing in
                if isShowing {
                    // Detener timer cuando se abre el sheet
                    timerShouldRun = false
                    refreshTimer?.invalidate()
                    refreshTimer = nil
                } else {
                    // Reiniciar timer cuando se cierra el sheet
                    timerShouldRun = true
                    startRefreshTimer()
                }
            }
            .onChange(of: showingCemetery) { isShowing in
                if isShowing {
                    // Detener timer cuando se abre el sheet
                    timerShouldRun = false
                    refreshTimer?.invalidate()
                    refreshTimer = nil
                } else {
                    // Reiniciar timer cuando se cierra el sheet
                    timerShouldRun = true
                    startRefreshTimer()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .petStatsChanged)) { _ in
                // No forzar re-render completo, solo actualizar valores
                // Esto evita interrumpir el scroll
            }
            .onReceive(NotificationCenter.default.publisher(for: .petLevelUp)) { _ in
                // No forzar re-render completo, solo actualizar valores
                // Esto evita interrumpir el scroll
            }
        }
    }
    
    private func startRefreshTimer() {
        // Detener timer existente si hay uno
        refreshTimer?.invalidate()
        
        // Solo iniciar si no hay sheet abierto
        guard !showingPetSelection && !showingTaskHistory && !showingCemetery, timerShouldRun else { return }
        
        // Usar un timer con intervalo más largo para evitar interferir con el scroll
        // El timer solo actualiza los valores, no fuerza re-renders completos
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            // Publicar una notificación para actualizar la vista
            // Esto evita problemas de captura en structs
            // Nota: No usamos refreshID aquí para evitar interrumpir el scroll
            NotificationCenter.default.post(name: .petStatsChanged, object: nil)
        }
    }
    
    private func healthColor(_ health: Int) -> Color {
        if health >= 80 { return .green }
        if health >= 50 { return .yellow }
        if health >= 20 { return .orange }
        return .red
    }
    
    private func happinessColor(_ happiness: Int) -> Color {
        if happiness >= 80 { return .pink }
        if happiness >= 50 { return .purple }
        return .blue
    }
    
    private func healthIcon(_ status: HealthStatus) -> String {
        switch status {
        case .healthy: return "heart.fill"
        case .okay: return "heart"
        case .sick: return "cross.case.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
    
    private func getHealthGlowColor(_ health: Int) -> Color {
        if health >= 80 { return .green }
        if health >= 50 { return .yellow }
        if health >= 20 { return .orange }
        return .red
    }
}

    struct PetCard: View {
        let pet: Pet
        let isSelected: Bool
        let isActive: Bool
        let onTap: () -> Void
        @EnvironmentObject var viewModel: AppViewModel
    
        var body: some View {
            Button(action: {
                // Verificar si hay tarea activa antes de permitir cambio
                if viewModel.activeTask != nil {
                    return
                }
                onTap()
            }) {
            VStack(spacing: 8) {
                // Badge de Activa
                if isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("ACTIVA")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.circle.fill")
                            .font(.caption2)
                        Text("INACTIVA")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray, Color.gray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                
                Text(pet.type.emoji)
                    .font(.system(size: 50))
                    .opacity(isActive ? 1.0 : 0.7)
                
                Text(pet.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text("Nv. \(pet.level)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Indicador de salud rápida
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 8))
                        .foregroundColor(healthColor(pet.health))
                    Text("\(pet.health)%")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(healthColor(pet.health))
                }
            }
            .padding()
            .frame(width: 120)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        isActive ?
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.2),
                                    Color.green.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.1),
                                    Color.gray.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isActive ?
                            LinearGradient(
                                colors: [Color.green.opacity(0.6), Color.green.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isActive ? 3 : 0
                    )
            )
            .shadow(
                color: isActive ? Color.green.opacity(0.3) : Color.clear,
                radius: isActive ? 10 : 0,
                x: 0,
                y: isActive ? 5 : 0
            )
            .scaleEffect(isActive ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
    
    private func healthColor(_ health: Int) -> Color {
        if health >= 80 { return .green }
        if health >= 50 { return .yellow }
        if health >= 20 { return .orange }
        return .red
    }
}

#Preview {
    PetStatusView()
        .environmentObject(AppViewModel())
}

