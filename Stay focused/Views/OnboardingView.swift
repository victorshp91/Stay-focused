//
//  OnboardingView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Contenido
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "🎯",
                        title: "Bienvenido a Stay Focused",
                        description: "Mantén tu productividad mientras cuidas de tu mascota virtual. Cada tarea completada hace crecer a tu compañero.",
                        color: .blue
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "⏰",
                        title: "Sistema de Check-ins",
                        description: "Completa check-ins en tiempo para verificar tu progreso. Tienes una ventana de tiempo limitada (20% del intervalo, min 2min, max 10min).",
                        color: .orange
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "🐾",
                        title: "Cuida a tu Mascota",
                        description: "Tu mascota necesita atención constante. Check-ins exitosos la mantienen saludable. Si descuidas, perderá salud y puede morir.",
                        color: .green
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        icon: "⭐",
                        title: "Sistema de Experiencia",
                        description: "Gana experiencia con cada acción exitosa. La experiencia requerida aumenta progresivamente. Mantén rachas largas para multiplicadores de XP.",
                        color: .purple
                    )
                    .tag(3)
                    
                    OnboardingPage(
                        icon: "🔥",
                        title: "Rachas y Recompensas",
                        description: "Mantén rachas de días consecutivos para multiplicar tu experiencia. La racha solo aumenta si completas tareas exitosamente Y tu mascota está viva.",
                        color: .red
                    )
                    .tag(4)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Botones
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                currentPage -= 1
                            }
                        }) {
                            Text("Anterior")
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        if currentPage < 4 {
                            withAnimation(.spring(response: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.5)) {
                                isPresented = false
                            }
                        }
                    }) {
                        Text(currentPage < 4 ? "Siguiente" : "Comenzar")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(icon)
                .font(.system(size: 100))
                .scaleEffect(animate ? 1.0 : 0.8)
                .opacity(animate ? 1.0 : 0.5)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

