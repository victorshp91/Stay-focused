//
//  ContentView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .onAppear {
                        showOnboarding = true
                    }
                    .onChange(of: showOnboarding) { newValue in
                        if !newValue {
                            hasSeenOnboarding = true
                        }
                    }
            } else {
                MainTabView()
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
