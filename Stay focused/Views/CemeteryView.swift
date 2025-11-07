//
//  CemeteryView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct CemeteryView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo tipo cementerio (oscuro y sombrío)
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.2, green: 0.15, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header estilo cementerio
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.gray.opacity(0.4),
                                                Color.gray.opacity(0.2),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .blur(radius: 20)
                                
                                Text("🪦")
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Cementerio")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Mascotas que han partido")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        if viewModel.deadPets.isEmpty {
                            // No hay mascotas muertas
                            VStack(spacing: 20) {
                                Text("🕊️")
                                    .font(.system(size: 80))
                                
                                Text("No hay mascotas en el cementerio")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Tus mascotas están vivas y saludables")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            )
                            .padding(.horizontal)
                        } else {
                            // Lista de mascotas muertas
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.deadPets) { pet in
                                    DeadPetCard(pet: pet)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Cementerio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct DeadPetCard: View {
    let pet: Pet
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.3, green: 0.3, blue: 0.35),
                        Color(red: 0.2, green: 0.2, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 15) {
                    // Emoji de la mascota (con opacidad reducida)
                    Text(pet.type.emoji)
                        .font(.system(size: 60))
                        .opacity(0.6)
                    
                    // Nombre
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Tipo
                    Text(pet.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Fecha de muerte
                    if let deathDate = pet.deathDate {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("Falleció el \(formatDate(deathDate))")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    }
                    
                    // Estadísticas finales
                    HStack(spacing: 30) {
                        StatItem(icon: "star.fill", label: "Nivel", value: "\(pet.level)")
                        StatItem(icon: "checkmark.circle.fill", label: "Tareas", value: "\(pet.completedTaskIds.count)")
                        StatItem(icon: "flame.fill", label: "Días", value: "\(pet.consecutiveDays)")
                    }
                    .padding(.top, 10)
                }
                .padding(20)
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.5),
                            Color.gray.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
        .opacity(animate ? 1.0 : 0.7)
        .scaleEffect(animate ? 1.0 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
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
}

struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    CemeteryView()
        .environmentObject(AppViewModel())
}

