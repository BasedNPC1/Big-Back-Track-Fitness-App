import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @State private var showingCamera = false
    @State private var showingManualEntry = false
    @State private var capturedImage: UIImage?
    @State private var isProcessingImage = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    @State private var errorMessage: String?
    
    // Manual entry states
    @State private var newFoodName = ""
    @State private var newFoodWeight = 100.0
    @State private var selectedUnit = "g"
    
    // Colors for the vibrant theme (matching other views)
    let darkBackground = Color.black
    let gradientStart = Color(red: 0.0, green: 0.8, blue: 0.8) // Teal
    let gradientEnd = Color(red: 0.5, green: 0.0, blue: 0.8) // Purple
    let accentColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Green
    let secondaryColor = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    let redColor = Color.red
    
    // Available units
    let units = ["g", "oz", "ml", "cup", "tbsp"]
    
    var body: some View {
        ZStack {
            // Background
            darkBackground.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                Text("SCAN FOOD")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("Take a photo or manually enter your food")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                // Camera button
                Button(action: {
                    showingCamera = true
                }) {
                    VStack(spacing: 15) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(accentColor)
                        
                        Text("Take Photo")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(secondaryColor)
                    )
                }
                .padding(.horizontal)
                
                // Manual entry button
                Button(action: {
                    showingManualEntry = true
                }) {
                    VStack(spacing: 15) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 40))
                            .foregroundColor(accentColor)
                        
                        Text("Manual Entry")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(secondaryColor)
                    )
                }
                .padding(.horizontal)
                
                // Success message
                if showingSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                        Text(successMessage)
                            .foregroundColor(accentColor)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(secondaryColor)
                    .cornerRadius(8)
                }
                
                // Error message
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(redColor)
                        Text(error)
                            .foregroundColor(redColor)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(secondaryColor)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            
            // Loading overlay
            if isProcessingImage {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        SwiftUI.ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                        
                        Text("Analyzing your food...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(secondaryColor)
                    .cornerRadius(15)
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea()
                .onDisappear {
                    if let image = capturedImage {
                        processImage(image)
                    }
                }
        }
        .sheet(isPresented: $showingManualEntry) {
            manualEntryView
        }
    }
    
    // Process the captured image
    private func processImage(_ image: UIImage) {
        isProcessingImage = true
        
        // In a real app, you would send this image to an AI service
        // For now, we'll simulate a delay and use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Create a mock food entry
            viewModel.addFoodEntry(name: "Scanned Food", weight: 100.0, unit: "g")
            
            // Show success message
            successMessage = "Added SCANNED FOOD (100g)"
            showingSuccessMessage = true
            
            // Hide success message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showingSuccessMessage = false
                }
            }
            
            // Reset state
            isProcessingImage = false
            capturedImage = nil
        }
    }
    
    // Manual entry view
    private var manualEntryView: some View {
        VStack(spacing: 20) {
            Text("Enter Food Details")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter food (e.g. chicken breast, banana):")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                TextField("", text: $newFoodName)
                    .padding()
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight/Amount:")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    HStack {
                        TextField("", value: $newFoodWeight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(secondaryColor)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                newFoodWeight = max(0, newFoodWeight - 10)
                            }) {
                                Text("-")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                            
                            Button(action: {
                                newFoodWeight += 10
                            }) {
                                Text("+")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                }
                
                // Unit picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit:")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Picker("", selection: $selectedUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).foregroundColor(.white)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(secondaryColor)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                // Add the food entry
                if !newFoodName.isEmpty {
                    viewModel.addFoodEntry(name: newFoodName, weight: newFoodWeight, unit: selectedUnit)
                    
                    // Show success message
                    successMessage = "Added \(newFoodName.uppercased()) (\(newFoodWeight)\(selectedUnit))"
                    showingSuccessMessage = true
                    
                    // Hide success message after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingSuccessMessage = false
                        }
                    }
                    
                    // Reset fields
                    newFoodName = ""
                    newFoodWeight = 100.0
                    selectedUnit = "g"
                    
                    // Dismiss sheet
                    showingManualEntry = false
                }
            }) {
                Text("ADD FOOD")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor, accentColor.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(newFoodName.isEmpty || viewModel.isLoading)
            .opacity((newFoodName.isEmpty || viewModel.isLoading) ? 0.6 : 1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(darkBackground)
    }
}

// Image Picker struct to handle camera access
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    CameraView(viewModel: FoodLogViewModel())
}
