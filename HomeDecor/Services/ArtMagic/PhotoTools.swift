//
//  PhotoTools.swift
//  HomeDecor
//

import UIKit
import AVFoundation
import Photos

/// Image helpers and permission checks of the Create flow.
enum PhotoTools {

    /// Upright pixels (EXIF rotation baked in), longest side at most `maxSide`.
    static func normalized(_ image: UIImage, maxSide: CGFloat = 2048) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > 0 else { return image }
        let factor = min(1, maxSide / longest)
        let size = CGSize(width: (image.size.width * factor).rounded(), height: (image.size.height * factor).rounded())
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
    }

    /// `rect` is in pixels of an image made by `normalized`.
    static func cropped(_ image: UIImage, to rect: CGRect) -> UIImage {
        guard let piece = image.cgImage?.cropping(to: rect.integral) else { return image }
        return UIImage(cgImage: piece, scale: 1, orientation: .up)
    }

    /// True when the average brightness is too low for a good redesign (the "Photo is too dark" popup).
    static func isTooDark(_ image: UIImage) -> Bool {
        guard let cg = image.cgImage else { return false }
        let side = 16
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: side, height: side, bitsPerComponent: 8, bytesPerRow: side * 4,
                                          space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(cg, in: CGRect(x: 0, y: 0, width: side, height: side))
            return true
        }
        guard drawn else { return false }
        var total = 0.0
        for i in stride(from: 0, to: pixels.count, by: 4) {
            total += 0.299 * Double(pixels[i]) + 0.587 * Double(pixels[i + 1]) + 0.114 * Double(pixels[i + 2])
        }
        return total / Double(side * side) / 255 < 0.18
    }

    /// A temporary JPEG the SDK can upload.
    static func jpegFile(_ image: UIImage) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.9) else { throw CocoaError(.fileWriteUnknown) }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Permissions

    enum Access { case granted, undetermined, denied }

    static var cameraAccess: Access {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .granted
        case .notDetermined: return .undetermined
        default: return .denied
        }
    }

    static var photosAccess: Access {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited: return .granted
        case .notDetermined: return .undetermined
        default: return .denied
        }
    }

    static func requestCamera() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    static func requestPhotos() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }

    @MainActor
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
    }

    /// Save an image to the system Photos library (prompts for add-access on
    /// first use via NSPhotoLibraryAddUsageDescription).
    @MainActor
    static func saveToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
