import Foundation
import UIKit

struct PhotoModel: Identifiable {
    let id: UUID
    let image: UIImage
    let localIdentifier: String
    var isHidden: Bool
}
