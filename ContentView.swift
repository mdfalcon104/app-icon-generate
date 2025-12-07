import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = IconGeneratorViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("App Icon Generator")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            // Drag and Drop Area
            DropZoneView(image: $viewModel.sourceImage)
                .frame(width: 300, height: 300)
            
            if viewModel.sourceImage != nil {
                // Corner Radius Options
                VStack(alignment: .leading, spacing: 10) {
                    Text("Corner Radius:")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        // First row: preset buttons
                        HStack(spacing: 8) {
                            ForEach([0, 4, 8, 16], id: \.self) { radius in
                                Button(action: {
                                    viewModel.selectedRadius = .preset(radius)
                                }) {
                                    Text("\(radius)px")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(viewModel.selectedRadius == .preset(radius) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(viewModel.selectedRadius == .preset(radius) ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Second row: custom input
                        HStack(spacing: 8) {
                            TextField("Custom", value: $viewModel.customRadius, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                viewModel.selectedRadius = .custom(viewModel.customRadius)
                            }) {
                                Text("Apply")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(viewModel.selectedRadius == .custom(viewModel.customRadius) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedRadius == .custom(viewModel.customRadius) ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Generate Logo Option
                Toggle(isOn: $viewModel.generateLogo) {
                    HStack {
                        Image(systemName: "square.on.circle")
                        Text("Also generate Logo.imageset")
                            .font(.subheadline)
                    }
                }
                .toggleStyle(.checkbox)
                .padding(.horizontal, 20)
                
                // Generate Button
                Button(action: {
                    viewModel.generateIcons()
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "photo.stack")
                        }
                        Text(viewModel.isGenerating ? "Generating..." : "Generate Icons")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isGenerating)
                .padding(.horizontal, 20)
                
                // Reveal in Finder Button
                if viewModel.outputPath != nil {
                    Button(action: {
                        viewModel.revealInFinder()
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Reveal in Finder")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                }
                
                if let message = viewModel.statusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(viewModel.isError ? .red : .green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(width: 450, height: 680)
    }
}

struct DropZoneView: View {
    @Binding var image: NSImage?
    @State private var isDragOver = false
    @State private var justDropped = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(isDragOver ? .blue : .gray)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDragOver ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                )
            
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Drag & Drop Image Here")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("PNG, JPG, or JPEG")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                    Text("or click to browse")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isDragOver && !justDropped {
                openFileDialog()
            }
        }
        .onDrop(of: [.image, .fileURL], isTargeted: $isDragOver) { providers in
            guard let provider = providers.first else { return false }
            
            // Set flag to prevent tap gesture from firing
            justDropped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                justDropped = false
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { data, error in
                    DispatchQueue.main.async {
                        if let url = data as? URL,
                           let nsImage = NSImage(contentsOf: url) {
                            self.image = nsImage
                        } else if let data = data as? Data,
                                  let nsImage = NSImage(data: data) {
                            self.image = nsImage
                        }
                    }
                }
                return true
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                    DispatchQueue.main.async {
                        if let url = data as? URL,
                           let nsImage = NSImage(contentsOf: url) {
                            self.image = nsImage
                        }
                    }
                }
                return true
            }
            
            return false
        }
    }
    
    private func openFileDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .image]
        panel.message = "Select an image file"
        
        if panel.runModal() == .OK {
            if let url = panel.url,
               let nsImage = NSImage(contentsOf: url) {
                self.image = nsImage
            }
        }
    }
}
