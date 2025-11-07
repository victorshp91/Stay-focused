//
//  PetSelectionView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct PetSelectionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: PetType?
    @State private var petName: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingPurchaseConfirmation = false
    @State private var purchasedPetType: PetType? // Tipo de mascota comprada esperando nombre
    @State private var showingNameInput = false // Mostrar diálogo para poner nombre después de compra
    
    var body: some View {
        ZStack {
                // Fondo moderno tipo juego
                GameColorTheme.petBackground()
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
                                
                                Text("🐾")
                                    .font(.system(size: 60))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Adopta una Mascota")
                                    .font(.system(size: 32, weight: .bold))
                                Text("Elige tu compañero perfecto")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Información sobre límite
                        if viewModel.pets.count >= 1 && !viewModel.settings.isPremium {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Límite de Mascota Gratuita")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                
                                Text("Ya tienes 1 mascota gratis. Puedes comprar mascotas adicionales individualmente.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.orange.opacity(0.2),
                                                Color.orange.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .orange.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Grid de mascotas estilo juego
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(PetType.allCases, id: \.self) { type in
                                GameStylePetCard(
                                    type: type,
                                    isSelected: selectedType == type,
                                    isOwned: viewModel.pets.contains(where: { $0.type == type }),
                                    onTap: {
                                        // Si ya tiene esta mascota, no puede seleccionarla
                                        if viewModel.pets.contains(where: { $0.type == type }) {
                                            alertMessage = "Ya tienes esta mascota"
                                            showingAlert = true
                                            return
                                        }
                                        
                                        // Si es gratis (gato) y no tiene mascotas, puede seleccionarla
                                        if type.price == 0.0 && viewModel.pets.count == 0 {
                                            selectedType = type
                                            return
                                        }
                                        
                                        // Si ya tiene 1 mascota gratis y quiere otra, debe comprarla
                                        if viewModel.pets.count >= 1 && type.price > 0.0 {
                                            selectedType = type
                                            showingPurchaseConfirmation = true
                                            return
                                        }
                                        
                                        // Si es gratis pero ya tiene mascota, debe comprar
                                        if type.price == 0.0 && viewModel.pets.count >= 1 {
                                            alertMessage = "Ya tienes tu mascota gratis. Puedes comprar mascotas adicionales."
                                            showingAlert = true
                                            return
                                        }
                                        
                                        selectedType = type
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Nombre de la mascota (solo para mascotas gratis)
                        if selectedType != nil && !viewModel.pets.contains(where: { $0.type == selectedType! }) {
                            // Solo mostrar campo de nombre para mascotas gratis
                            if let type = selectedType, type.price == 0.0 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Nombre de tu Mascota")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Escribe un nombre...", text: $petName)
                                        .textFieldStyle(.plain)
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
                                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                        )
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("El nombre no se puede cambiar después")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 5)
                                }
                                .padding(.horizontal)
                                
                                // Botón de adoptar (gratis)
                                Button(action: {
                                    addPet()
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Adoptar Mascota")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: getTypeGradient(selectedType ?? .cat),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(
                                        color: getTypeGradient(selectedType ?? .cat)[0].opacity(0.5),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                }
                                .disabled(petName.isEmpty)
                                .opacity(petName.isEmpty ? 0.6 : 1.0)
                                .padding(.horizontal)
                            } else {
                                // Para mascotas de pago, solo mostrar botón de compra
                                Button(action: {
                                    showingPurchaseConfirmation = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "creditcard.fill")
                                        Text("Comprar por \(selectedType?.formattedPrice ?? "")")
                                    }
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: getTypeGradient(selectedType ?? .cat),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(
                                        color: getTypeGradient(selectedType ?? .cat)[0].opacity(0.5),
                                        radius: 20,
                                        x: 0,
                                        y: 10
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Nueva Mascota")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
        .alert("Información", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Confirmar Compra", isPresented: $showingPurchaseConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Comprar \(selectedType?.formattedPrice ?? "")") {
                // Primero procesar la compra
                if let type = selectedType {
                    purchasedPetType = type
                    // En producción, aquí se integraría con StoreKit
                    // Por ahora, simulamos la compra exitosa
                    showingNameInput = true
                }
            }
        } message: {
            if let type = selectedType {
                Text("¿Deseas comprar \(type.rawValue) por \(type.formattedPrice)?\n\nDespués de la compra podrás ponerle un nombre a tu mascota.")
            }
        }
        .sheet(isPresented: $showingNameInput) {
            if let type = purchasedPetType {
                PetNameInputSheet(
                    petType: type,
                    petName: $petName,
                    onConfirm: {
                        if !petName.isEmpty {
                            finalizePetPurchase(type: type)
                        }
                    },
                    onCancel: {
                        petName = ""
                        purchasedPetType = nil
                    }
                )
            }
        }
    }
    
    private func addPet() {
        guard let type = selectedType, !petName.isEmpty else { return }
        
        // Si es gratis y ya tiene mascota, no puede agregar
        if type.price == 0.0 && viewModel.pets.count >= 1 {
            alertMessage = "Ya tienes tu mascota gratis. Puedes comprar mascotas adicionales."
            showingAlert = true
            return
        }
        
        // Crear y agregar la mascota
        let pet = Pet(name: petName, type: type, isPremium: type.isPremium)
        viewModel.addPet(pet)
        dismiss()
    }
    
    private func finalizePetPurchase(type: PetType) {
        guard !petName.isEmpty else { return }
        
        // Crear y agregar la mascota con el nombre
        let pet = Pet(name: petName, type: type, isPremium: type.isPremium)
        viewModel.addPet(pet)
        
        // Limpiar estados
        petName = ""
        purchasedPetType = nil
        selectedType = nil
        
        dismiss()
    }
    
    private func getTypeGradient(_ type: PetType) -> [Color] {
        switch type {
        case .cat: return [Color.blue, Color.purple]
        case .dog: return [Color.orange, Color.pink]
        case .rabbit: return [Color.pink, Color.purple]
        case .dragon: return [Color.red, Color.orange]
        case .unicorn: return [Color.purple, Color.pink]
        case .phoenix: return [Color.orange, Color.red]
        case .robot: return [Color.gray, Color.blue]
        case .alien: return [Color.green, Color.cyan]
        }
    }
}

struct GameStylePetCard: View {
    let type: PetType
    let isSelected: Bool
    let isOwned: Bool
    let onTap: () -> Void
    @State private var animate = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Gradiente de fondo
                ZStack {
                    LinearGradient(
                        colors: getGradientColors(),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Emoji de la mascota
                    VStack(spacing: 10) {
                        Text(type.emoji)
                            .font(.system(size: 70))
                            .scaleEffect(animate ? 1.1 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animate)
                        
                        Text(type.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .padding(.top, 20)
                    
                    // Badge de precio o "Ya tienes"
                    VStack {
                        HStack {
                            Spacer()
                            if isOwned {
                                ZStack {
                                    Capsule()
                                        .fill(Color.green.opacity(0.9))
                                        .frame(width: 80, height: 25)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption2)
                                        Text("Tienes")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                }
                                .padding(8)
                            } else {
                                ZStack {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: type.price == 0.0 ?
                                                    [Color.green.opacity(0.9), Color.green.opacity(0.9)] :
                                                    [Color(red: 1.0, green: 0.7, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: type.price == 0.0 ? 70 : 90, height: 25)
                                    
                                    Text(type.formattedPrice)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                            }
                        }
                        Spacer()
                    }
                    
                    // Lock overlay para premium no desbloqueado
                    if type.isPremium && !isOwned {
                        ZStack {
                            Color.black.opacity(0.3)
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                Text("Premium")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: 180)
                
                // Información inferior
                VStack(spacing: 8) {
                    // Stats simuladas
                    HStack(spacing: 15) {
                        StatIcon(icon: "heart.fill", value: "9.6K", color: .red)
                        StatIcon(icon: "bolt.fill", value: "879", color: .yellow)
                        StatIcon(icon: "person.fill", value: "255", color: .blue)
                    }
                    .padding(.top, 10)
                    
                    // Estrellas
                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    
                    Text("5.3K Adopciones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color(red: 0.95, green: 0.95, blue: 1.0).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        isSelected ?
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 4 : 0
                    )
            )
            .shadow(
                color: getGradientColors()[0].opacity(isSelected ? 0.5 : 0.3),
                radius: isSelected ? 25 : 15,
                x: 0,
                y: isSelected ? 12 : 8
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            animate = true
        }
    }
    
    private func getGradientColors() -> [Color] {
        switch type {
        case .cat: return [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]
        case .dog: return [Color.orange.opacity(0.8), Color.orange.opacity(0.4)]
        case .rabbit: return [Color.pink.opacity(0.8), Color.pink.opacity(0.4)]
        case .dragon: return [Color.red.opacity(0.8), Color.red.opacity(0.4)]
        case .unicorn: return [Color.purple.opacity(0.8), Color.purple.opacity(0.4)]
        case .phoenix: return [Color.orange.opacity(0.8), Color.orange.opacity(0.4)]
        case .robot: return [Color.gray.opacity(0.8), Color.gray.opacity(0.4)]
        case .alien: return [Color.green.opacity(0.8), Color.green.opacity(0.4)]
        }
    }
}

struct StatIcon: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
    }
}

// MARK: - Pet Name Input Sheet
struct PetNameInputSheet: View {
    let petType: PetType
    @Binding var petName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo moderno tipo juego
                GameColorTheme.petBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header con emoji de la mascota
                    VStack(spacing: 15) {
                        Text(petType.emoji)
                            .font(.system(size: 80))
                        
                        VStack(spacing: 8) {
                            Text("¡Felicidades!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Has comprado \(petType.rawValue)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Campo de nombre
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ponle un nombre a tu mascota")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        TextField("Escribe un nombre...", text: $petName)
                            .textFieldStyle(.plain)
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
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                        
                        // Advertencia sobre el nombre
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Importante")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                
                                Text("El nombre no se puede cambiar después de confirmar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Botones
                    VStack(spacing: 15) {
                        Button(action: {
                            onConfirm()
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Confirmar Nombre")
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
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
                            .shadow(color: Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                        .disabled(petName.isEmpty)
                        .opacity(petName.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: {
                            onCancel()
                            dismiss()
                        }) {
                            Text("Cancelar")
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.3))
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nombre de Mascota")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PetSelectionView()
        .environmentObject(AppViewModel())
}
