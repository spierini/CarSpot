//
//  SpotLocale.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/15/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//


import Foundation
import MapKit
import Firebase

class SpotLocale : NSObject, MKAnnotation {
    
    //MKAnnotation protocol vars
    var coordinate: CLLocationCoordinate2D
    let ref: FIRDatabaseReference?
    var title: String? //spot name
    var subtitle: String? //Traffic: low, medium, high
    
    var latitude: Double
    var longitude: Double
    
    init(coord: CLLocationCoordinate2D, named: String, detail: String) {
        coordinate = coord
        title = named
        subtitle = detail
        latitude = coord.latitude
        longitude = coord.longitude
        ref = nil
        //call super class initializer second rather than first
        super.init()
    }
    
    init(snapshot: FIRDataSnapshot) {
        title = snapshot.key
        let snapvalues = snapshot.value as! [String : AnyObject]
        print("snapvalues: \(snapvalues)")
        //title = snapvalues["city"] as! String
        subtitle = snapvalues["traffic"] as? String
        //get coordinates
        coordinate = CLLocationCoordinate2D(latitude: snapvalues["latitude"] as! Double, longitude: snapvalues["longitude"] as! Double)
        
        longitude = (snapvalues["longitude"] as? Double)!
        latitude = (snapvalues["latitude"] as? Double)!
        ref = snapshot.ref
        
        //call super class initializer second rather than first
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "name" : title!,
            "latitude" : latitude,
            "longitude" : longitude,
            "traffic" : subtitle!
        ]
    }
    
}
