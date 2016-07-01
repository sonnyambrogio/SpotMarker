//
//  Annotation.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-30.
//  Copyright © 2016 Sonny. All rights reserved.
//

import Foundation
import RealmSwift

class Annotation: Object {
    
    dynamic var title: String = ""
    dynamic var longitude: Double = 0.0
    dynamic var latitude: Double = 0.0
    dynamic var info: String = ""
    dynamic var date: NSDate?
    
    convenience init(title: String, longitude: Double, latitude: Double, info: String, date: NSDate) {
        self.init()
        self.title = title
        self.longitude = longitude
        self.latitude = latitude
        self.info = info
        self.date = date
    }
}