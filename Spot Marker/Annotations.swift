//
//  Annotations.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-26.
//  Copyright © 2016 Sonny. All rights reserved.
//

import Foundation
import RealmSwift

class Annotations: Object {
    
    dynamic var title: String = ""
    dynamic var longitude: Double = 0.0
    dynamic var latitude: Double = 0.0
    dynamic var info: String = ""
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
