//
//  Example.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/29/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import Foundation
import UIKit
typealias Image = UIImage

let MB = 1024 * 1024

func exampleError(error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "ExampleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}

extension String {
    func toFloat() -> Float? {
        let numberFormatter = NSNumberFormatter()
        return numberFormatter.numberFromString(self)?.floatValue
    }
    
    func toDouble() -> Double? {
        let numberFormatter = NSNumberFormatter()
        return numberFormatter.numberFromString(self)?.doubleValue
    }
}

func showAlert(message: String) {
    UIAlertView(title: "RxExample", message: message, delegate: nil, cancelButtonTitle: "OK").show()
}