//
//  SpotLocale.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/15/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//


import Foundation
import MapKit

class SpotLocale : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(coord: CLLocationCoordinate2D, named: String, detail: String) {
        coordinate = coord
        title = named
        subtitle = detail
        //call super class initializer second rather than first
        super.init()
    }
    
}
