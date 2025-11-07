//
//  StreaksView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct StreaksView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Tarjeta Principal de Racha - Estilo de juego
                        VStack(spacing: 20) {
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.orange.opacity(0.4),
                                                Color.red.opacity(0.2),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 120
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 30)
                                
                                Text("🔥")
                                    .font(.system(size: 100))
                                    .scaleEffect(viewModel.streak.currentStreak > 0 ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.5), value: viewModel.streak.currentStreak)
                            }
                            
                            VStack(spacing: 10) {
                                Text("Racha Actual")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(viewModel.streak.currentStreak)")
                                    .font(.system(size: 72, weight: .bold))
                                    .foregroundColor(.orange)
                                    .contentTransition(.numericText())
                                    .overlay(
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .mask(
                                            Text("\(viewModel.streak.currentStreak)")
                                                .font(.system(size: 72, weight: .bold))
                                        )
                                    )
                                
                                Text("días consecutivos")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            if viewModel.streak.milestone != .none {
                                let milestone = viewModel.streak.milestone
                                HStack(spacing: 12) {
                                    Text(milestone.badge)
                                        .font(.system(size: 30))
                                    Text(milestone.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.orange, Color.red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            }
                        }
                        .padding(35)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 35)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.7, blue: 0.4).opacity(0.4),
                                            Color(red: 1.0, green: 0.5, blue: 0.3).opacity(0.3),
                                            Color(red: 1.0, green: 0.6, blue: 0.7).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.5), radius: 30, x: 0, y: 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 35)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.7),
                                                    Color.white.opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                        )
                        .padding(.horizontal)
                        
                        // Estadísticas - Estilo de juego
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Estadísticas")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Tarjetas de estadísticas
                            HStack(spacing: 15) {
                                StatCard(
                                    icon: "flame.fill",
                                    value: "\(viewModel.streak.currentStreak)",
                                    label: "Días Actuales",
                                    color: .orange
                                )
                                
                                StatCard(
                                    icon: "trophy.fill",
                                    value: "\(viewModel.streak.longestStreak)",
                                    label: "Récord",
                                    color: .yellow
                                )
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 15) {
                                StatCard(
                                    icon: "calendar.fill",
                                    value: "\(viewModel.streak.totalDays)",
                                    label: "Total Días",
                                    color: .blue
                                )
                                
                                StatCard(
                                    icon: "star.fill",
                                    value: "\(viewModel.streak.milestone != .none ? "1" : "0")",
                                    label: "Logros",
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        // Próximos hitos
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Próximos Hitos")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(StreakMilestone.allCases.filter { $0 != .none }, id: \.self) { milestone in
                                if milestone.rawValue > viewModel.streak.currentStreak {
                                    MilestoneCard(
                                        milestone: milestone,
                                        currentStreak: viewModel.streak.currentStreak,
                                        isUnlocked: false
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Rachas")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animate)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.2), color.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            animate = true
        }
    }
}

struct MilestoneCard: View {
    let milestone: StreakMilestone
    let currentStreak: Int
    let isUnlocked: Bool
    
    var progress: Double {
        min(1.0, Double(currentStreak) / Double(milestone.rawValue))
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Text(milestone.badge)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(milestone.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Barra de progreso
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 12)
                
                Text("\(currentStreak) / \(milestone.rawValue) días")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .font(.title2)
                .foregroundColor(isUnlocked ? .green : .gray)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color(red: 1.0, green: 0.95, blue: 0.9).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.2), radius: 15, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.orange.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
}

#Preview {
    StreaksView()
        .environmentObject(AppViewModel())
}
