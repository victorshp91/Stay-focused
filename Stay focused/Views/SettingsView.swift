//
//  SettingsView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingPremium = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                GameColorTheme.settingsBackground()
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
                                
                                Text("⚙️")
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Configuración")
                                    .font(.system(size: 32, weight: .bold))
                                Text("Personaliza tu experiencia")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Estado Premium
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: viewModel.settings.isPremium ? "crown.fill" : "crown")
                                    .font(.title2)
                                    .foregroundColor(viewModel.settings.isPremium ? Color(red: 1.0, green: 0.7, blue: 0.2) : .gray)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(viewModel.settings.isPremium ? "Premium Activo" : "Versión Gratuita")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Text(viewModel.settings.isPremium ? "Disfruta de todas las funciones" : "Actualiza para desbloquear más")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if !viewModel.settings.isPremium {
                                    Button("Ver Premium") {
                                        showingPremium = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color(red: 1.0, green: 0.7, blue: 0.2))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal)
                        
                        // Configuración de Notificaciones
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Notificaciones")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(spacing: 12) {
                                ToggleSetting(
                                    icon: "bell.fill",
                                    title: "Notificaciones",
                                    isOn: $viewModel.settings.notificationsEnabled
                                )
                                
                                ToggleSetting(
                                    icon: "clock.fill",
                                    title: "Recordatorios de Check-in",
                                    isOn: $viewModel.settings.checkInReminders
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal)
                        
                        // Información de Mascotas
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "pawprint.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Mascotas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Mascotas Disponibles")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(viewModel.pets.count) / \(viewModel.settings.maxPets)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            }
                            
                            if !viewModel.settings.isPremium {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption)
                                    Text("Versión gratuita: máximo 1 mascota")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal)
                        
                        // Estadísticas
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Estadísticas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(spacing: 12) {
                                StatRow(
                                    icon: "list.bullet.rectangle",
                                    title: "Total de Tareas",
                                    value: "\(viewModel.tasks.count)"
                                )
                                
                                StatRow(
                                    icon: "flame.fill",
                                    title: "Racha Actual",
                                    value: "\(viewModel.streak.currentStreak) días",
                                    valueColor: .orange
                                )
                                
                                StatRow(
                                    icon: "star.fill",
                                    title: "Insignias Desbloqueadas",
                                    value: "\(viewModel.badges.filter { $0.isUnlocked }.count) / \(viewModel.badges.count)"
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal)
                        
                        // Recompensas y Penalizaciones
                        NavigationLink(destination: PenaltiesRewardsView()) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text("Recompensas y Penalizaciones")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.7, green: 0.6, blue: 1.0).opacity(0.3),
                                                Color(red: 0.6, green: 0.7, blue: 1.0).opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.6, green: 0.5, blue: 0.9).opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Información de la App
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Acerca de")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Versión")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Divider()
                                
                                Link(destination: URL(string: "https://example.com/support")!) {
                                    HStack {
                                        Image(systemName: "questionmark.circle.fill")
                                            .foregroundColor(.blue)
                                        Text("Soporte")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Link(destination: URL(string: "https://example.com/privacy")!) {
                                    HStack {
                                        Image(systemName: "lock.shield.fill")
                                            .foregroundColor(.blue)
                                        Text("Política de Privacidad")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 15, x: 0, y: 8)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPremium) {
                PremiumView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct ToggleSetting: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .secondary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}
