import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhotoViewModel()
    @State private var showPhotoPicker = false
    @State private var showSecretPhotos = false

    var body: some View {
        NavigationView {
            VStack {
                Button("Fotoğraf Seç") {
                    showPhotoPicker = true
                }
                .sheet(isPresented: $showPhotoPicker) {
                    PhotoPickerView(viewModel: viewModel)
                }
                
                Button("Gizli Fotoğrafları Göster") {
                    viewModel.authenticateWithFaceID { success in
                        if success {
                            showSecretPhotos = true
                        }
                    }
                }
                .sheet(isPresented: $showSecretPhotos) {
                    SecretPhotosView(viewModel: viewModel)
                }
                
                List(viewModel.photos) { photo in
                    HStack {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Button("Gizle") {
                            viewModel.hidePhoto(photo)
                        }
                    }
                }
            }
            .navigationBarTitle("Fotoğraflar")
        }
        .onAppear {
            viewModel.fetchPhotos()
        }
    }
}

// PreviewProvider ekleyelim
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
