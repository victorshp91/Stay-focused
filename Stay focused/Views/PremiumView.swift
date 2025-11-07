//
//  PremiumView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: PremiumTab = .subscription
    
    enum PremiumTab {
        case subscription
        case pets
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo premium con gradiente dorado
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.8),
                        Color(red: 1.0, green: 0.9, blue: 0.7),
                        Color(red: 0.98, green: 0.85, blue: 0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header estilo juego
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.6),
                                                Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.3),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 150, height: 150)
                                    .blur(radius: 30)
                                
                                Text("⭐")
                                    .font(.system(size: 80))
                            }
                            
                            VStack(spacing: 10) {
                                Text("Stay Focused Premium")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Elige cómo quieres mejorar tu experiencia")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Tabs de navegación
                        HStack(spacing: 0) {
                            PremiumTabButton(
                                title: "Suscripción",
                                isSelected: selectedTab == .subscription,
                                action: { selectedTab = .subscription }
                            )
                            PremiumTabButton(
                                title: "Mascotas",
                                isSelected: selectedTab == .pets,
                                action: { selectedTab = .pets }
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        // Contenido según tab seleccionado
                        Group {
                            switch selectedTab {
                            case .subscription:
                                SubscriptionView(viewModel: viewModel, purchasePremium: purchasePremium)
                            case .pets:
                                PetsPurchaseView(viewModel: viewModel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium")
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
    
    private func purchasePremium() {
        // En producción, aquí se integraría con StoreKit
        // Por ahora, simulamos la compra
        viewModel.upgradeToPremium()
        dismiss()
    }
}

// MARK: - Tab Button
struct PremiumTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ?
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.7, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .cornerRadius(12)
        }
    }
}

// MARK: - Subscription View
struct SubscriptionView: View {
    @ObservedObject var viewModel: AppViewModel
    let purchasePremium: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // Comparación Gratis vs Premium
            VStack(alignment: .leading, spacing: 15) {
                Text("Comparación")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ComparisonRow(
                    feature: "Mascotas",
                    free: "1 gratis",
                    premium: "Ilimitadas"
                )
                ComparisonRow(
                    feature: "Mascotas Exclusivas",
                    free: "No",
                    premium: "Sí (Dragón, Unicornio, Fénix, etc.)"
                )
                ComparisonRow(
                    feature: "Compra Individual",
                    free: "Sí ($1.99 - $3.99)",
                    premium: "Incluidas"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color(red: 1.0, green: 0.95, blue: 0.85).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
            )
            
            // Beneficios Premium
            VStack(alignment: .leading, spacing: 15) {
                Text("Beneficios Premium")
                    .font(.title2)
                    .fontWeight(.bold)
                
                PremiumFeature(
                    icon: "pawprint.fill",
                    title: "Mascotas Ilimitadas",
                    description: "Crea y cuida tantas mascotas como quieras sin restricciones"
                )
                
                PremiumFeature(
                    icon: "sparkles",
                    title: "Mascotas Exclusivas Incluidas",
                    description: "Todas las mascotas premium desbloqueadas sin costo adicional"
                )
                
                PremiumFeature(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Estadísticas Avanzadas",
                    description: "Análisis detallado de tu productividad y progreso"
                )
                
                PremiumFeature(
                    icon: "bell.badge.fill",
                    title: "Notificaciones Personalizadas",
                    description: "Configura recordatorios y alertas a tu medida"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color(red: 1.0, green: 0.95, blue: 0.85).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
            )
            
            // Precio y botón
            if !viewModel.settings.isPremium {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("$4.99")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                        
                        Text("por mes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.9),
                                        Color(red: 1.0, green: 0.95, blue: 0.85).opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                    
                    Button(action: purchasePremium) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                            Text("Activar Premium")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.2),
                                    Color(red: 1.0, green: 0.5, blue: 0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .orange.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 40)
                    
                    Text("Cancela en cualquier momento")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("¡Premium Activo!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Disfruta de todos los beneficios premium")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Pets Purchase View
struct PetsPurchaseView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Compra de Mascotas Individuales")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Puedes comprar mascotas individuales sin necesidad de suscripción premium. Cada mascota tiene su propio precio.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Información sobre versión gratuita
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Versión Gratuita")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text("• 1 mascota gratis (Gato)")
                    .font(.subheadline)
                Text("• Puedes comprar mascotas adicionales individualmente")
                    .font(.subheadline)
                Text("• Cada mascota se compra una sola vez")
                    .font(.subheadline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // Lista de precios
            VStack(alignment: .leading, spacing: 12) {
                Text("Precios de Mascotas")
                    .font(.headline)
                    .fontWeight(.bold)
                
                ForEach(PetType.allCases, id: \.self) { type in
                    HStack {
                        Text(type.emoji)
                            .font(.title2)
                        Text(type.rawValue)
                            .font(.subheadline)
                        Spacer()
                        if type.price == 0.0 {
                            Text("Gratis")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        } else {
                            Text(type.formattedPrice)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.5))
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
                                Color(red: 1.0, green: 0.95, blue: 0.85).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
            )
            
            // Nota sobre premium
            if !viewModel.settings.isPremium {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                        Text("Con Premium")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text("Con la suscripción premium ($4.99/mes), todas las mascotas exclusivas están incluidas sin costo adicional.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.5),
                                    Color(red: 1.0, green: 0.9, blue: 0.7).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                            Color(red: 1.0, green: 0.95, blue: 0.85).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Helper Views
struct ComparisonRow: View {
    let feature: String
    let free: String
    let premium: String
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 120, alignment: .leading)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Gratis: \(free)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Premium: \(premium)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
            }
        }
        .padding(.vertical, 8)
    }
}

struct PremiumFeature: View {
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
                            colors: [Color(red: 1.0, green: 0.7, blue: 0.3), Color(red: 1.0, green: 0.5, blue: 0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.1 : 1.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color(red: 1.0, green: 0.95, blue: 0.9).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .orange.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal)
    }
}

#Preview {
    PremiumView()
        .environmentObject(AppViewModel())
}

