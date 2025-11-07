//
//  PenaltiesRewardsView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct PenaltiesRewardsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.98),
                        Color(red: 0.94, green: 0.96, blue: 1.0),
                        Color(red: 0.92, green: 0.94, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header estilo juego
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.4),
                                                Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 20)
                                
                                Text("📚")
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Sistema de Recompensas")
                                    .font(.system(size: 28, weight: .bold))
                                Text("y Penalizaciones")
                                    .font(.system(size: 28, weight: .bold))
                                Text("Todo lo que necesitas saber")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Sección de Recompensas
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("✨")
                                    .font(.title)
                                Text("Recompensas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            }
                            .padding(.horizontal)
                        
                        RewardPenaltyCard(
                            icon: "checkmark.circle.fill",
                            title: "Check-in Exitoso",
                            description: "Completas un check-in y es verificado por la IA",
                            healthChange: "+10",
                            happinessChange: "+5",
                            experienceChange: "10 XP",
                            isReward: true,
                            note: "Con multiplicador de racha: 7+ días (1.5x), 14+ días (2.0x), 30+ días (2.5x)"
                        )
                        
                        RewardPenaltyCard(
                            icon: "trophy.fill",
                            title: "Tarea Completada Exitosamente",
                            description: "Completas una tarea con ≥70% de check-ins verificados",
                            healthChange: "+10",
                            happinessChange: "+5",
                            experienceChange: "20 XP",
                            isReward: true,
                            note: "Con multiplicador de racha aplicado. Bonificación al subir de nivel: +5 salud, +10 felicidad"
                        )
                        
                        RewardPenaltyCard(
                            icon: "flame.fill",
                            title: "Racha Actualizada",
                            description: "Completas una tarea exitosamente y tu mascota está viva",
                            healthChange: "—",
                            happinessChange: "—",
                            experienceChange: "—",
                            isReward: true,
                            note: "Aumenta tu racha de días consecutivos"
                        )
                        
                        RewardPenaltyCard(
                            icon: "arrow.up.circle.fill",
                            title: "Subir de Nivel",
                            description: "Acumulas suficiente experiencia (progresivo)",
                            healthChange: "+5",
                            happinessChange: "+10",
                            experienceChange: "—",
                            isReward: true,
                            note: "Experiencia requerida aumenta progresivamente. Nivel máximo: 25. Fórmula: 10 × (nivel^1.5)"
                        )
                    }
                    .padding(.vertical)
                    
                    Divider()
                        .padding(.horizontal)
                    
                        // Sección de Penalizaciones
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("⚠️")
                                    .font(.title)
                                Text("Penalizaciones")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                            .padding(.horizontal)
                        
                        RewardPenaltyCard(
                            icon: "xmark.circle.fill",
                            title: "Check-in Perdido",
                            description: "No completas un check-in dentro de la ventana de tiempo",
                            healthChange: "-15",
                            happinessChange: "-10",
                            experienceChange: "0",
                            isReward: false
                        )
                        
                        RewardPenaltyCard(
                            icon: "xmark.circle.fill",
                            title: "Check-in Fallido",
                            description: "El check-in no es verificado por la IA",
                            healthChange: "-15",
                            happinessChange: "-10",
                            experienceChange: "0",
                            isReward: false
                        )
                        
                        RewardPenaltyCard(
                            icon: "xmark.shield.fill",
                            title: "Tarea Cancelada",
                            description: "Cancelas una tarea activa",
                            healthChange: "-30",
                            happinessChange: "-20",
                            experienceChange: "0",
                            isReward: false,
                            note: "Penalización doble por abandonar"
                        )
                        
                        RewardPenaltyCard(
                            icon: "xmark.circle.fill",
                            title: "Tarea No Exitosa",
                            description: "Completas una tarea con <70% de check-ins verificados",
                            healthChange: "-15",
                            happinessChange: "-10",
                            experienceChange: "0",
                            isReward: false
                        )
                        
                        RewardPenaltyCard(
                            icon: "clock.fill",
                            title: "Deterioro por Inactividad",
                            description: "No hay tarea activa y la mascota no ha sido alimentada en 24 horas",
                            healthChange: "-1",
                            happinessChange: "-1",
                            experienceChange: "0",
                            isReward: false,
                            note: "Cada 30 segundos hasta que la mascota muera o se complete una tarea"
                        )
                    }
                    .padding(.vertical)
                    
                        // Información Adicional
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("ℹ️")
                                    .font(.title)
                                Text("Información Importante")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))
                            }
                            .padding(.horizontal)
                        
                        InfoCard(
                            icon: "heart.fill",
                            title: "Muerte de la Mascota",
                            description: "Si la salud de tu mascota llega a 0, la mascota muere. No podrás aumentar tu racha hasta que crees una nueva mascota."
                        )
                        
                        InfoCard(
                            icon: "flame.fill",
                            title: "Sistema de Rachas",
                            description: "La racha solo aumenta cuando completas una tarea exitosamente (≥70% de check-ins) Y tu mascota está viva."
                        )
                        
                        InfoCard(
                            icon: "clock.fill",
                            title: "Ventana de Check-in",
                            description: "Cada check-in tiene una ventana de tiempo (20% del intervalo, mínimo 2 min, máximo 10 min). Si no lo completas en ese tiempo, se pierde automáticamente."
                        )
                        
                        InfoCard(
                            icon: "star.fill",
                            title: "Sistema de Experiencia Progresivo",
                            description: "La experiencia requerida aumenta con cada nivel. Nivel 1: ~10 XP, Nivel 5: ~56 XP, Nivel 10: ~158 XP, Nivel 25: ~625 XP. Mantener rachas largas multiplica la experiencia ganada."
                        )
                        
                        InfoCard(
                            icon: "flame.fill",
                            title: "Multiplicador de Racha",
                            description: "Racha 0-6 días: x1.0 | 7-13 días: x1.5 | 14-29 días: x2.0 | 30+ días: x2.5. Aplica a check-ins exitosos y tareas completadas."
                        )
                        }
                        .padding(.vertical)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Recompensas y Penalizaciones")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct RewardPenaltyCard: View {
    let icon: String
    let title: String
    let description: String
    let healthChange: String
    let happinessChange: String
    let experienceChange: String
    let isReward: Bool
    var note: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isReward ? .green : .red)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                StatChange(label: "Salud", value: healthChange, isReward: isReward)
                StatChange(label: "Felicidad", value: happinessChange, isReward: isReward)
                StatChange(label: "Experiencia", value: experienceChange, isReward: isReward)
            }
            
            if let note = note {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isReward ?
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.15),
                                Color(red: 0.3, green: 0.9, blue: 0.5).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.15),
                                Color(red: 1.0, green: 0.4, blue: 0.4).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .shadow(
                    color: (isReward ? Color.green : Color.red).opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    (isReward ? Color.green : Color.red).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .padding(.horizontal)
    }
}

struct StatChange: View {
    let label: String
    let value: String
    let isReward: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(value == "—" || value == "0" ? .secondary : (isReward ? .green : .red))
        }
        .frame(maxWidth: .infinity)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    @State private var animate = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.6, blue: 1.0),
                                Color(red: 0.3, green: 0.7, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 35, height: 35)
                    .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .scaleEffect(animate ? 1.1 : 1.0)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.15),
                            Color(red: 0.3, green: 0.7, blue: 1.0).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}

#Preview {
    PenaltiesRewardsView()
}

