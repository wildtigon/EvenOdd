//
//  UIImageView+DownloadableImage.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/29/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension UIImageView{

    var rxex_downloadableImage: AnyObserver<DownloadableImage>{
        return self.rxex_downloadableImageAnimated(nil)
    }

    func rxex_downloadableImageAnimated(transitionType:String?) -> AnyObserver<DownloadableImage> {
        return UIBindingObserver(UIElement: self) { imageView, image in
            for subview in imageView.subviews {
                subview.removeFromSuperview()
            }
            switch image {
            case .Content(let image):
                imageView.rx_image.onNext(image)
            case .OfflinePlaceholder:
                let label = UILabel(frame: imageView.bounds)
                label.textAlignment = .Center
                label.font = UIFont.systemFontOfSize(35)
                label.text = "⚠️"
                imageView.addSubview(label)
            }
        }.asObserver()
    }
}
