import SwiftUI

struct SecretPhotosView: View {
    @ObservedObject var viewModel: PhotoViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(viewModel.secretPhotos) { photo in
                HStack {
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Button("Görünür Yap") {
                        viewModel.unhidePhoto(photo)
                    }
                }
            }
            .navigationBarTitle("Gizli Fotoğraflar")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// PreviewProvider ekleyelim
struct SecretPhotosView_Previews: PreviewProvider {
    static var previews: some View {
        SecretPhotosView(viewModel: PhotoViewModel())
    }
}
