//
//  UIImageView+Cache.swift
//  Reporters App
//
//  Created by sijo on 23/04/20.
//  Copyright © 2020 Hifx. All rights reserved.
//

import UIKit
import AVFoundation

private let imageCache = NSCache<NSString, UIImage>()

fileprivate extension AWSS3Scheduler {
    var mediaPath: String {
        !mediaURL.contains(AWS.S3.bucket) ? "https://s3-eu-west-1.amazonaws.com/\(AWS.S3.bucket)" + mediaURL : mediaURL
    }
}

extension UIImageView {
    func load(from s3: AWSS3Scheduler, to size: CGSize = .zero, placeholder: UIImage? = nil) {
        
        // MARK: - Image Resize Helper Methods Declaration
        //----------------------------------------------------------------------------------------------
        
        let isThumbView = size == .zero || size.width <= UIScreen.main.bounds.size.width / 3
        
        func setPlaceholder() {
            let placeHolder = (placeholder ?? UIImage(named: isThumbView ? s3.placeHolder : s3.mediaType.previewHolder))
            let image = s3 is Reporter ? placeHolder : placeHolder?.withRenderingMode(.alwaysTemplate)
            enqueueUIStack {
                if isThumbView {
                    self.contentMode = .scaleAspectFit
                }
                self.image = image
            }
        }
        
        let cachePath: String = {
            let mediaPath = s3.mediaPath
            guard size == .zero else { return mediaPath }
            return mediaPath + "Thumb"
        }()
        
        func resize(for image: UIImage, isAnimate: Bool = false, isCacheEnabled: Bool = true) {
            DispatchQueue.global(qos: .utility).async {
                let size = size == .zero ? UIImage.TargetSize.low.size : size
                let resizedImage = image.resize(to: size)
                if isCacheEnabled {
                    imageCache.setObject(resizedImage, forKey: cachePath as NSString)
                }
                enqueueUIStack {
                    if isThumbView {
                        self.contentMode = .scaleAspectFill
                    }
                    self.image = resizedImage
                    if isAnimate {
                        self.animateTransition()
                    }
                }
            }
        }
        
        /// Loads image from web asynchronosly and caches it, in case you have to load url
        /// again, it will be loaded from cache if available
        func download() {
            guard let url = URL(string: s3.mediaPath) else { return }
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, _, _) in
                guard let data = data ,
                      let image = UIImage(data: data) else { return }
                resize(for: image, isAnimate: true)
            }).resume()
        }
        
        // MARK: - Image Resize Helper Methods Implementation
        //----------------------------------------------------------------------------------------------
        if !s3.isUploaded || s3.mediaType != .image {
            if let localFile = s3.thumbnail, s3.mediaType != .audio {
                resize(for: localFile, isCacheEnabled: false)
                return
            }
            
            setPlaceholder()
            return
        }
        
        if let cachedImage = imageCache.object(forKey: cachePath as NSString) {
            resize(for: cachedImage)
            return
        }
        
        setPlaceholder()
        download()
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.6
        case high    = 0.75
        case highest = 1
    }
    
    func jpegData(compression quality: JPEGQuality = .medium) -> Data? {
        jpegData(compressionQuality: quality.rawValue)
    }
}

extension UIImage {
    enum TargetSize {
        case low, high, custom(CGSize)
        var size: CGSize {
            switch self {
            case .low: return .init(width: 180.0, height: 180.0)
            case .high: return .init(width: 845.0, height: 440.0)
            case .custom(let size): return size
            }
        }
        var description: String { String(describing: self) }
    }
    
    func resizeWith(padding newSize: CGSize) -> UIImage {
        let aspectSize = aspectRatio(of: newSize)
        let renderer = UIGraphicsImageRenderer(size: aspectSize)
        let image = renderer.image { (context) in
            draw(in: .init(origin: .zero, size: aspectSize))
        }
        return image.add(padding: newSize)
    }
    
    func resized(maxSize: CGSize = UIImage.TargetSize.high.size, compressionQuality: Float = 0.6) -> Data? {
        let frame = CGRect(origin: .zero, size: aspectRatio(of: maxSize))
        UIGraphicsBeginImageContext(frame.size)
        draw(in: frame)
        
         let renderer = UIGraphicsImageRenderer(size: maxSize)
        let image = renderer.image { (context) in
            draw(in: .init(origin: .init(x: (maxSize.width - frame.size.width)/2, y: (maxSize.height - frame.size.height)/2), size: frame.size))
        }
        let imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
      UIGraphicsEndImageContext()
      return imageData
    }
}

fileprivate extension UIImage {
    func aspectRatio(of size: CGSize) -> CGSize {
        let rect = CGRect(origin: .zero, size: size)
        let frame = AVMakeRect(aspectRatio: self.size, insideRect: rect)
        return frame.size
    }
    
    func add(padding forSize: CGSize) -> UIImage {
        guard (size.height > size.width) else { return self }
        let leftPadding = (forSize.width - size.width) / 2
        return withAlignmentRectInsets(.init(top: 0, left: -leftPadding, bottom: 0, right: 0))
    }
    
    func resize(to size: CGSize) -> UIImage {
        let newSize = aspectRatio(of: size)
        guard newSize != self.size, let cgImage = self.cgImage?.resize(to: newSize) else { return self }
        return .init(cgImage: cgImage)
    }
}

extension CGImage {
    func resize(to newSize: CGSize) -> CGImage? {
        guard let colorSpace = self.colorSpace,
            let context = CGContext(data: nil,
                                    width: Int(newSize.width),
                                    height: Int(newSize.height),
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(self, in: .init(origin: .zero, size: newSize))
        return context.makeImage()
    }
}
