//
//  PetTasksHistoryView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct PetTasksHistoryView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    let pet: Pet
    
    var completedTasks: [Task] {
        viewModel.completedTasks(for: pet)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GameColorTheme.petBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
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
                                
                                Text(pet.type.emoji)
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text(pet.name)
                                    .font(.system(size: 28, weight: .bold))
                                Text("Historial de Tareas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Estadísticas rápidas
                            HStack(spacing: 30) {
                                QuickStat(
                                    icon: "checkmark.circle.fill",
                                    value: "\(completedTasks.count)",
                                    label: "Tareas"
                                )
                                QuickStat(
                                    icon: "star.fill",
                                    value: "\(pet.level)",
                                    label: "Nivel"
                                )
                                QuickStat(
                                    icon: "flame.fill",
                                    value: "\(pet.consecutiveDays)",
                                    label: "Días"
                                )
                            }
                            .padding(.top, 10)
                        }
                        .padding(.top, 20)
                        
                        if completedTasks.isEmpty {
                            // No hay tareas completadas
                            VStack(spacing: 20) {
                                Text("📝")
                                    .font(.system(size: 80))
                                
                                Text("Aún no hay tareas completadas")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("Completa tareas con esta mascota para verlas aquí")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
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
                                    .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 20, x: 0, y: 10)
                            )
                            .padding(.horizontal)
                        } else {
                            // Lista de tareas completadas
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Tareas Completadas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 15) {
                                    ForEach(completedTasks.sorted(by: { ($0.endTime ?? Date.distantPast) > ($1.endTime ?? Date.distantPast) })) { task in
                                        CompletedTaskCard(task: task)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuickStat: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
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
                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

struct CompletedTaskCard: View {
    let task: Task
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icono de tarea completada
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.4),
                                    Color(red: 0.3, green: 0.9, blue: 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if let endTime = task.endTime {
                        Text("Completada el \(formatDate(endTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // Estadísticas de la tarea
            HStack(spacing: 20) {
                TaskStat(
                    icon: "clock.fill",
                    label: "Duración",
                    value: formatDuration(task.duration)
                )
                TaskStat(
                    icon: "camera.fill",
                    label: "Check-ins",
                    value: "\(task.checkIns.filter { $0.isVerified }.count)/\(task.checkIns.count)"
                )
                TaskStat(
                    icon: "percent",
                    label: "Éxito",
                    value: "\(Int(task.completionRate * 100))%"
                )
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 18)
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
                .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .opacity(animate ? 1.0 : 0.0)
        .offset(x: animate ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TaskStat: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PetTasksHistoryView(pet: Pet(name: "Test", type: .cat))
        .environmentObject(AppViewModel())
}

