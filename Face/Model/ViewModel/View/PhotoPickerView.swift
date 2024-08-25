import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    var viewModel: PhotoViewModel

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPickerView
        var viewModel: PhotoViewModel
        
        init(_ parent: PhotoPickerView, viewModel: PhotoViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        result.itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier as String, options: nil) { (item, error) in
                            if let url = item as? URL {
                                let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
                                if let asset = fetchResult.firstObject {
                                    let localIdentifier = asset.localIdentifier
                                    let photo = PhotoModel(id: UUID(), image: image, localIdentifier: localIdentifier, isHidden: false)
                                    DispatchQueue.main.async {
                                        self.viewModel.photos.append(photo)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
