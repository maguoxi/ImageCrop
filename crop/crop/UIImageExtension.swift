//
//  UIImageExtension.swift
//  crop
//
//  Created by 马国玺 on 2020/7/27.
//

import UIKit

extension UIImage {
    ///裁剪image，rect是相对于image.size大小
    public func cropping(to rect: CGRect) -> UIImage? {
        guard self.size.width > rect.origin.x else {
            return nil
        }
        guard self.size.height > rect.origin.y else {
            return nil
        }
        let scaleRect = CGRect(x: rect.origin.x*self.scale, y: rect.origin.y*self.scale, width: rect.width*self.scale, height: rect.height*self.scale)
        if let cgImage = self.cgImage?.cropping(to: scaleRect) {
            let cropImage = UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)
            return cropImage
        } else {
            return nil
        }
    }
}
