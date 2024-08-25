import SwiftUI
import Photos
import LocalAuthentication

class PhotoViewModel: ObservableObject {
    @Published var photos: [PhotoModel] = []
    @Published var secretPhotos: [PhotoModel] = []

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                fetchResult.enumerateObjects { (asset, _, _) in
                    let manager = PHImageManager.default()
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options) { (image, _) in
                        if let image = image {
                            let photoModel = PhotoModel(id: UUID(), image: image, localIdentifier: asset.localIdentifier, isHidden: false)
                            DispatchQueue.main.async {
                                self.photos.append(photoModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func hidePhoto(_ photo: PhotoModel) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            var hiddenPhoto = photos[index]
            hiddenPhoto.isHidden = true
            photos.remove(at: index)
            secretPhotos.append(hiddenPhoto)
            deletePhotoFromLibrary(photo)
        }
    }
    
    func unhidePhoto(_ photo: PhotoModel) {
        if let index = secretPhotos.firstIndex(where: { $0.id == photo.id }) {
            var visiblePhoto = secretPhotos[index]
            visiblePhoto.isHidden = false
            secretPhotos.remove(at: index)
            photos.append(visiblePhoto)
            savePhotoToLibrary(photo)
        }
    }

    private func deletePhotoFromLibrary(_ photo: PhotoModel) {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [photo.localIdentifier], options: nil)

        if let asset = fetchResult.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: { success, error in
                if success {
                    print("Fotoğraf başarıyla silindi")
                } else if let error = error {
                    print("Fotoğraf silinemedi: \(error)")
                }
            })
        }
    }
    
    private func savePhotoToLibrary(_ photo: PhotoModel) {
        UIImageWriteToSavedPhotosAlbum(photo.image, self, #selector(saveError(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Fotoğraf kaydedilemedi: \(error.localizedDescription)")
        } else {
            print("Fotoğraf başarıyla kaydedildi")
        }
    }

    func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Gizli fotoğraflara erişmek için FaceID kullanın.") { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
}
