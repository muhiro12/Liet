import UIKit

extension UIImage {
    var batchHasAlphaChannel: Bool {
        cgImage?.batchHasAlphaChannel ?? false
    }
}
