//
//  Spot.swift
//  Spot Marker
//
//  Created by Sonny on 2016-07-01.
//  Copyright © 2016 Sonny. All rights reserved.
//

import Foundation
import MapKit



class Spot: NSObject, MKAnnotation {
    var title: String?
    var info: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, info: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.info = info
        self.coordinate = coordinate
    }
}