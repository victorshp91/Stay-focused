//
//  RewardsView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego con mejor contraste
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.96, blue: 0.99),
                        Color(red: 0.96, green: 0.94, blue: 0.98),
                        Color(red: 0.94, green: 0.92, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                    // Resumen con estilo de juego
                    VStack(spacing: 15) {
                        HStack {
                            Text("🏆")
                                .font(.system(size: 40))
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Colección de Insignias")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("\(unlockedBadgesCount) / \(viewModel.badges.count) desbloqueadas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        // Barra de progreso mejorada
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progreso")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int((Double(unlockedBadgesCount) / Double(viewModel.badges.count)) * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2))
                                    )
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Fondo
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 20)
                                    
                                    // Progreso con gradiente
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * (Double(unlockedBadgesCount) / Double(viewModel.badges.count)),
                                            height: 20
                                        )
                                        .animation(.spring(response: 0.5), value: unlockedBadgesCount)
                                }
                            }
                            .frame(height: 20)
                        }
                        
                        // Puntos totales con mejor contraste
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                            Text("Puntos Totales: \(viewModel.totalPoints)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.95, blue: 0.85),
                                            Color(red: 1.0, green: 0.9, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.95),
                                        Color(red: 0.98, green: 0.97, blue: 1.0).opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.15), radius: 20, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.6),
                                                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                    .padding(.horizontal)
                    
                    // Insignias por Categoría
                    ForEach(BadgeCategory.allCases, id: \.self) { category in
                        BadgeCategorySection(
                            category: category,
                            badges: viewModel.badges.filter { $0.category == category }
                        )
                    }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Recompensas")
        }
    }
    
    private var unlockedBadgesCount: Int {
        viewModel.badges.filter { $0.isUnlocked }.count
    }
}

struct BadgeCategorySection: View {
    let category: BadgeCategory
    let badges: [Badge]
    @State private var animate = false
    
    var categoryIcon: String {
        switch category {
        case .streak: return "🔥"
        case .completion: return "✅"
        case .consistency: return "⏰"
        case .special: return "⭐"
        }
    }
    
    var categoryColor: Color {
        switch category {
        case .streak: return Color(red: 1.0, green: 0.5, blue: 0.2)
        case .completion: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .consistency: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .special: return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(categoryIcon)
                    .font(.title)
                Text(category.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(badges.filter { $0.isUnlocked }.count)/\(badges.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor, categoryColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal)
            .opacity(animate ? 1.0 : 0.0)
            .offset(x: animate ? 0 : -20)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                ForEach(Array(badges.enumerated()), id: \.element.id) { index, badge in
                    BadgeCard(badge: badge)
                        .opacity(animate ? 1.0 : 0.0)
                        .offset(y: animate ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                            value: animate
                        )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    @State private var animate = false
    @State private var glowAnimation = false
    
    var body: some View {
        ZStack {
            // Glow effect para insignias desbloqueadas
            if badge.isUnlocked {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        RadialGradient(
                            colors: [
                                badge.rarity.glowColor.opacity(glowAnimation ? 0.4 : 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .blur(radius: 15)
                    .frame(height: 180)
            }
            
            VStack(spacing: 10) {
                // Rarity indicator
                HStack {
                    Spacer()
                    Text(badge.rarity.rawValue.uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [badge.rarity.color, badge.rarity.color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                
                Text(badge.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(badge.isUnlocked && animate ? 1.15 : 1.0)
                    .rotationEffect(.degrees(badge.isUnlocked && animate ? 360 : 0))
                    .animation(
                        badge.isUnlocked ? 
                            .spring(response: 0.6, dampingFraction: 0.7) : 
                            .default,
                        value: animate
                    )
                
                Text(badge.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if badge.isUnlocked {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                            if let date = badge.unlockedDate {
                                Text(formatDate(date))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.2))
                                .font(.caption2)
                            Text("\(badge.points) pts")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        
                        Text("\(badge.points) pts")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: badge.isUnlocked ? 
                                getRarityGradient(badge.rarity) :
                                [
                                    Color.white.opacity(0.9),
                                    Color.gray.opacity(0.1)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        badge.isUnlocked ? 
                            LinearGradient(
                                colors: [badge.rarity.color.opacity(0.6), badge.rarity.color.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: badge.isUnlocked ? 2 : 1
                    )
            )
            .shadow(
                color: badge.isUnlocked ? badge.rarity.glowColor.opacity(0.3) : .clear,
                radius: badge.isUnlocked ? 10 : 0,
                x: 0,
                y: 5
            )
            .opacity(badge.isUnlocked ? 1.0 : 0.7)
            .scaleEffect(badge.isUnlocked && animate ? 1.02 : 1.0)
        }
        .onAppear {
            if badge.isUnlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        animate = true
                    }
                }
                
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowAnimation = true
                }
            }
        }
    }
    
    private func getRarityGradient(_ rarity: BadgeRarity) -> [Color] {
        switch rarity {
        case .common:
            return [Color.white.opacity(0.95), Color.gray.opacity(0.1)]
        case .rare:
            return [Color.white.opacity(0.95), Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.15)]
        case .epic:
            return [Color.white.opacity(0.95), Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2)]
        case .legendary:
            return [Color.white.opacity(0.95), Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.2)]
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

extension BadgeCategory: CaseIterable {
    static var allCases: [BadgeCategory] {
        [.streak, .completion, .consistency, .special]
    }
}

#Preview {
    RewardsView()
        .environmentObject(AppViewModel())
}
