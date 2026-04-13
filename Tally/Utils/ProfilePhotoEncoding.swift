//
//  ProfilePhotoEncoding.swift
//  Tally
//
//  Created by Mazen Tarek on 4/12/26.
//

import UIKit

// Attribution: GenAI helped me create this, the purpose of this is to compress an image and convert it to a base64 string
// for storage in firestore.
enum ProfilePhotoEncoding {

    // Compresses image to be under 1MB which is the limit for firestore.
    static func jpegBase64(fromImageData data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }

        let maxDimensions: [CGFloat] = [512, 400, 320]
        let qualities: [CGFloat] = [0.72, 0.55, 0.4, 0.28]

        for dimension in maxDimensions {
            let scaled = image.resized(maxDimension: dimension)
            for quality in qualities {
                guard let jpeg = scaled.jpegData(compressionQuality: quality) else { continue }
                let encoded = jpeg.base64EncodedString()
                if encoded.count <= 700_000 {
                    return encoded
                }
            }
        }
        return nil
    }

    static func uiImage(fromBase64 string: String?) -> UIImage? {
        guard let string, let data = Data(base64Encoded: string) else { return nil }
        return UIImage(data: data)
    }
}

private extension UIImage {

    func resized(maxDimension: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        let longest = max(w, h)
        guard longest > maxDimension else { return self }

        let scale = maxDimension / longest
        let newSize = CGSize(width: w * scale, height: h * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
