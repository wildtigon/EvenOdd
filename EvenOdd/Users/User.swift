//
//  User.swift
//  EvenOdd
//
//  Created by Nguyễn Tiến Đạt on 3/21/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    dynamic var name = ""
    dynamic var score = 0
    dynamic var time = NSDate(timeIntervalSince1970: 1)
}
