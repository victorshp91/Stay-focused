//
//  BadgeUnlockAnimationView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct BadgeUnlockAnimationView: View {
    let badge: Badge
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180
    @State private var glowIntensity: Double = 0.0
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            // Fondo oscuro semitransparente
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 30) {
                // Insignia con animación
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    badge.rarity.glowColor,
                                    badge.rarity.glowColor.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .opacity(glowIntensity)
                        .blur(radius: 20)
                    
                    // Insignia
                    VStack(spacing: 15) {
                        Text(badge.emoji)
                            .font(.system(size: 80))
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotation))
                        
                        Text("¡INSIGNIA DESBLOQUEADA!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(badge.rarity.color)
                        
                        Text(badge.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(badge.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Rarity badge
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(badge.rarity.color)
                            Text(badge.rarity.rawValue)
                                .fontWeight(.semibold)
                                .foregroundColor(badge.rarity.color)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(badge.rarity.color.opacity(0.2))
                        )
                        
                        // Points
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("+\(badge.points) puntos")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        badge.rarity.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: badge.rarity.glowColor, radius: 30, x: 0, y: 15)
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        isPresented = false
                    }
                }) {
                    Text("¡Genial!")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [badge.rarity.color, badge.rarity.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: badge.rarity.glowColor, radius: 15, x: 0, y: 8)
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 0
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
        }
    }
}

#Preview {
    BadgeUnlockAnimationView(
        badge: Badge(name: "Maestro", description: "Completa 50 tareas", emoji: "👑", category: .completion, rarity: .epic, points: 100),
        isPresented: .constant(true)
    )
}

