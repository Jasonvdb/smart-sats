//
//  QR.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/09.
//

#if os(iOS)
import UIKit
import CoreImage.CIFilterBuiltins

extension String {
    var qr: UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(self.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

#else

import AppKit

extension String {
    var qr: NSImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = self.data(using: String.Encoding.ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else { return nil }
        let scaleX = NSScreen.main?.backingScaleFactor ?? 1.0
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleX)
        let qrCodeImage = NSImage(ciImage: outputImage.transformed(by: transform))
        
        return qrCodeImage
    }
}

#endif
