//
//  RulesView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) var dismiss
    
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
                        // Header
                        VStack(spacing: 10) {
                            Text("📚")
                                .font(.system(size: 60))
                            Text("Guía Completa")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Todo lo que necesitas saber")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Reglas principales
                        RuleSection(
                            icon: "🎯",
                            title: "Cómo Funciona",
                            items: [
                                "Crea una tarea con duración e intervalo de check-ins",
                                "Completa check-ins tomando fotos durante la tarea",
                                "La IA verifica que estés cumpliendo con la tarea",
                                "Tu mascota gana experiencia y salud con cada éxito",
                                "Mantén a tu mascota viva para aumentar tu racha"
                            ]
                        )
                        
                        RuleSection(
                            icon: "⏰",
                            title: "Sistema de Check-ins",
                            items: [
                                "Cada check-in tiene una ventana de tiempo limitada",
                                "Ventana = 20% del intervalo (mín 2min, máx 10min)",
                                "Si no completas en tiempo, se marca como perdido",
                                "Check-ins perdidos penalizan a tu mascota",
                                "Múltiples check-ins perdidos pueden matar a tu mascota"
                            ]
                        )
                        
                        RuleSection(
                            icon: "🐾",
                            title: "Cuidado de la Mascota",
                            items: [
                                "Salud: 0-100 (si llega a 0, la mascota muere)",
                                "Felicidad: 0-100 (aumenta con éxito)",
                                "Check-in exitoso: +10 salud, +5 felicidad",
                                "Check-in perdido: -15 salud, -10 felicidad",
                                "Tarea cancelada: -30 salud, -20 felicidad (penalización doble)"
                            ]
                        )
                        
                        RuleSection(
                            icon: "⭐",
                            title: "Sistema de Experiencia",
                            items: [
                                "Check-in exitoso: 10 XP (con multiplicador de racha)",
                                "Tarea completada: 20 XP (con multiplicador de racha)",
                                "Experiencia requerida aumenta progresivamente",
                                "Fórmula: 10 × (nivel^1.5)",
                                "Nivel máximo: 25 (con corona especial)",
                                "Al subir de nivel: +5 salud, +10 felicidad"
                            ]
                        )
                        
                        RuleSection(
                            icon: "🔥",
                            title: "Multiplicador de Racha",
                            items: [
                                "0-6 días: x1.0 (sin bonificación)",
                                "7-13 días: x1.5 (50% más experiencia)",
                                "14-29 días: x2.0 (100% más experiencia)",
                                "30+ días: x2.5 (150% más experiencia)",
                                "La racha solo aumenta si completas tareas exitosamente",
                                "Tu mascota debe estar viva para aumentar la racha"
                            ]
                        )
                        
                        RuleSection(
                            icon: "💎",
                            title: "Consejos Pro",
                            items: [
                                "Mantén rachas largas para maximizar experiencia",
                                "No canceles tareas - la penalización es severa",
                                "Completa check-ins a tiempo para evitar pérdidas",
                                "Cuida a tu mascota - si muere, no puedes aumentar racha",
                                "El nivel máximo es 25, pero mantener rachas es clave"
                            ]
                        )
                        
                        // Link a recompensas y penalizaciones
                        NavigationLink(destination: PenaltiesRewardsView()) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.title3)
                                Text("Ver Recompensas y Penalizaciones Detalladas")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(15)
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
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Reglas del Juego")
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
    
}

struct RuleSection: View {
    let icon: String
    let title: String
    let items: [String]
    @State private var animate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
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
                                .frame(width: 24, height: 24)
                                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 2)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(x: animate ? 0 : -20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: animate
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(20)
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
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    RulesView()
}

