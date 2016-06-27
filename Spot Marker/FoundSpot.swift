//
//  Annotations.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-22.
//  Copyright © 2016 Sonny. All rights reserved.
//

import UIKit
import MapKit

class FoundSpot: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }

}
