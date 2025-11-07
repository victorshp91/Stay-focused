//
//  TaskSetupView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct TaskSetupView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var taskTitle: String = ""
    @State private var durationMinutes: Double = 30.0 // Cambiar a minutos, mínimo 5
    @Environment(\.dismiss) var dismiss
    
    // Calcular intervalo automáticamente basado en la duración
    private var calculatedCheckInInterval: TimeInterval {
        let duration = durationMinutes * 60 // Convertir a segundos
        
        // Calcular intervalo basado en la duración
        // Objetivo: 4-6 check-ins por tarea
        let targetCheckIns = 5.0 // Número objetivo de check-ins
        var interval = duration / targetCheckIns
        
        // Ajustar intervalo según la duración:
        // - Tareas muy cortas (5-15 min): mínimo 5 minutos entre check-ins
        // - Tareas cortas (15-30 min): 5-10 minutos
        // - Tareas medianas (30 min - 2 horas): 10-20 minutos
        // - Tareas largas (2-8 horas): 20-60 minutos
        
        if duration <= 15 * 60 { // 15 minutos o menos
            interval = 5 * 60 // Mínimo 5 minutos
        } else if duration <= 30 * 60 { // 30 minutos o menos
            interval = max(5 * 60, min(interval, 10 * 60)) // Entre 5 y 10 minutos
        } else if duration <= 2 * 3600 { // 2 horas o menos
            interval = max(10 * 60, min(interval, 20 * 60)) // Entre 10 y 20 minutos
        } else { // Más de 2 horas
            interval = max(20 * 60, min(interval, 60 * 60)) // Entre 20 y 60 minutos
        }
        
        return interval
    }
    
    // Calcular número de check-ins
    private var numberOfCheckIns: Int {
        let duration = durationMinutes * 60
        return max(1, Int(duration / calculatedCheckInInterval))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.92, blue: 1.0),
                        Color(red: 0.92, green: 0.95, blue: 1.0),
                        Color(red: 0.9, green: 0.92, blue: 0.98)
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
                                
                                Text("📝")
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Nueva Tarea")
                                    .font(.system(size: 32, weight: .bold))
                                Text("Configura tu sesión de trabajo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Nombre de la tarea
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Nombre de la Tarea")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            TextField("Ej: Estudiar matemáticas", text: $taskTitle)
                                .textFieldStyle(.plain)
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
                        .padding(.horizontal)
                        
                        // Duración
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                Text("Duración de la Tarea")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(formatTime(durationMinutes * 60))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                            }
                            
                            VStack(spacing: 10) {
                                Slider(value: $durationMinutes, in: 5...480, step: 5) // 5 minutos a 8 horas (480 min)
                                    .tint(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.4, blue: 1.0),
                                                Color(red: 0.4, green: 0.6, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                HStack {
                                    Text("5 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("8 horas")
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
                        
                        // Información de Check-ins (Automático)
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                Text("Check-ins Automáticos")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                // Número de check-ins
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total de Check-ins")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(numberOfCheckIns)")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Intervalo")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(formatTime(calculatedCheckInInterval))")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1),
                                                    Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.1)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                
                                // Información sobre la ventana de tiempo
                                HStack(spacing: 10) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("El intervalo se calcula automáticamente según la duración")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("Ventana de tiempo: \(formatTime(calculateWindowTime(calculatedCheckInInterval)))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
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
                        
                        // Botón de iniciar
                        Button(action: startTask) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Iniciar Tarea")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                taskTitle.isEmpty ?
                                    LinearGradient(
                                        colors: [Color.gray, Color.gray.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.6, green: 0.4, blue: 1.0),
                                            Color(red: 0.4, green: 0.6, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .cornerRadius(20)
                            .shadow(
                                color: taskTitle.isEmpty ?
                                    .clear :
                                    Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.4),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                        }
                        .disabled(taskTitle.isEmpty)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private func calculateWindowTime(_ interval: TimeInterval) -> TimeInterval {
        let windowPercentage = 0.2
        var windowTime = interval * windowPercentage
        let minWindow: TimeInterval = 2 * 60
        let maxWindow: TimeInterval = 10 * 60
        windowTime = max(minWindow, min(windowTime, maxWindow))
        return windowTime
    }
    
    private func startTask() {
        let task = Task(
            title: taskTitle,
            duration: durationMinutes * 60, // Convertir minutos a segundos
            checkInInterval: calculatedCheckInInterval // Usar el intervalo calculado automáticamente
        )
        viewModel.startTask(task)
        dismiss()
    }
}

#Preview {
    TaskSetupView()
        .environmentObject(AppViewModel())
}
