//
//  MainTabView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            PetStatusView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Mascota", systemImage: "pawprint.fill")
                }
            
            StreaksView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Rachas", systemImage: "flame.fill")
                }
            
            RewardsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Recompensas", systemImage: "trophy.fill")
                }
            
            SettingsView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Configuración", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.purple)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}

