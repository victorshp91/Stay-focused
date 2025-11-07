//
//  CheckInView.swift
//  Stay focused
//
//  Created by Victor Saint Hilaire on 11/6/25.
//

import SwiftUI
import PhotosUI

struct CheckInView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingCamera = false
    @State private var isProcessing = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var timerID = UUID() // Para forzar actualización de la vista
    @Environment(\.dismiss) var dismiss
    
    func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    func calculateWindowTime(for task: Task) -> TimeInterval {
        let windowPercentage = 0.2 // 20%
        var windowTime = task.checkInInterval * windowPercentage
        
        // Aplicar límites: mínimo 2 minutos, máximo 10 minutos
        let minWindow: TimeInterval = 2 * 60 // 2 minutos
        let maxWindow: TimeInterval = 10 * 60 // 10 minutos
        
        windowTime = max(minWindow, min(windowTime, maxWindow))
        return windowTime
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if let task = viewModel.activeTask {
                        VStack(spacing: 25) {
                            // Header estilo juego
                            VStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.blue.opacity(0.4),
                                                    Color.purple.opacity(0.2),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 20,
                                                endRadius: 80
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 20)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Check-in Requerido")
                                    .font(.system(size: 28, weight: .bold))
                                
                                Text(task.title)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                            
                            if let nextCheckIn = task.nextCheckInTime {
                                Text("Check-in debido: \(nextCheckIn, style: .time)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Timer estilo juego
                            if timeRemaining > 0 {
                                let isOverdue = timeRemaining <= 0 || task.isCheckInOverdue
                                VStack(spacing: 12) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "clock.fill")
                                            .font(.title2)
                                            .foregroundColor(isOverdue ? .red : .orange)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Tiempo Restante")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(formatTimeRemaining(timeRemaining))
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(isOverdue ? .red : .orange)
                                                .contentTransition(.numericText())
                                                .id(timerID) // Forzar actualización cuando cambia el timer
                                        }
                                    }
                                    
                                    let windowTime = calculateWindowTime(for: task)
                                    Text("Ventana: \(formatTimeRemaining(windowTime))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: isOverdue ?
                                                [Color.red.opacity(0.2), Color.red.opacity(0.1)] :
                                                    [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: isOverdue ? .red.opacity(0.3) : .orange.opacity(0.3), radius: 15, x: 0, y: 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            isOverdue ? Color.red.opacity(0.5) : Color.orange.opacity(0.5),
                                            lineWidth: 2
                                        )
                                )
                                .scaleEffect(isOverdue ? 1.02 : 1.0)
                                .animation(.spring(response: 0.3), value: isOverdue)
                            } else if task.isCheckInOverdue {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Check-in Perdido")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                        Text("Se aplicará penalización")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.red.opacity(0.2), Color.red.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .red.opacity(0.3), radius: 15, x: 0, y: 8)
                                )
                            }
                            
                            // Área de foto - Estilo juego
                            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .blue.opacity(0.2), radius: 15, x: 0, y: 8)
                                    
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 300)
                                        .cornerRadius(20)
                                        .padding()
                                }
                            } else {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.3),
                                                        Color.purple.opacity(0.1),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 20,
                                                    endRadius: 80
                                                )
                                            )
                                            .frame(width: 150, height: 150)
                                            .blur(radius: 20)
                                        
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text("Toma una foto para verificar")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .blue.opacity(0.2), radius: 15, x: 0, y: 8)
                                )
                            }
                            
                            // Botones de acción - Estilo juego
                            VStack(spacing: 15) {
                                HStack(spacing: 15) {
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle.fill")
                                            Text("Galería")
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    
                                    Button(action: { showingCamera = true }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Cámara")
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                }
                                
                                if photoData != nil {
                                    Button(action: submitCheckIn) {
                                        HStack {
                                            if isProcessing {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            } else {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("Enviar Check-in")
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                colors: [Color.purple, Color.pink],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 8)
                                    }
                                    .disabled(isProcessing)
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        } // Cierra VStack(spacing: 25)
                    } else {
                        Text("No hay tarea activa")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .navigationTitle("Check-in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
                .task(id: selectedPhoto) {
                    if let selectedPhoto = selectedPhoto {
                        if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }
                .sheet(isPresented: $showingCamera) {
                    CameraView(photoData: $photoData)
                }
                .onAppear {
                    updateTimeRemaining()
                    startTimer()
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
                .onChange(of: viewModel.activeTask?.id) { _ in
                    // Reiniciar timer cuando cambia la tarea
                    timer?.invalidate()
                    updateTimeRemaining()
                    startTimer()
                }
                .onReceive(NotificationCenter.default.publisher(for: .updateCheckInTimer)) { _ in
                    // Actualizar el tiempo restante cuando se recibe la notificación del timer
                    updateTimeRemaining()
                    
                    // Detener el timer si el tiempo llegó a 0
                    if timeRemaining <= 0 {
                        timer?.invalidate()
                        timer = nil
                    }
                }
            }
        }
    }
    
    private func updateTimeRemaining() {
        if let task = viewModel.activeTask, let remaining = task.timeRemainingForCheckIn {
            timeRemaining = max(0, remaining) // Asegurar que no sea negativo
        } else {
            timeRemaining = 0
        }
    }
    
    private func startTimer() {
        timer?.invalidate() // Invalidar timer anterior si existe
        timer = nil
        
        // Crear un nuevo timer que se ejecute cada segundo
        // Usar un enfoque que funcione con structs de SwiftUI
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Usar NotificationCenter para actualizar el estado de forma segura
            NotificationCenter.default.post(name: .updateCheckInTimer, object: nil)
        }
        
        self.timer = timer
        
        // Asegurar que el timer se ejecute en el main run loop para que funcione incluso durante scroll
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func submitCheckIn() {
        isProcessing = true
        viewModel.performCheckIn(photoData: photoData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            dismiss()
        }
    }
}
struct CameraView: UIViewControllerRepresentable {
    @Binding var photoData: Data?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.photoData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CheckInView()
        .environmentObject(AppViewModel())
}

