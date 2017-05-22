//
//  MapViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/15/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var spotImage: UIImage?
    //saved location when user had parked
    var spotCoordinate: CLLocationCoordinate2D? //35.300618, -120.662464   (on campus - where parked)
    
    //current location of user trying to find their car
    var currentCoordinate = CLLocationCoordinate2D(latitude: 35.281076, longitude: -120.660846)
    
    var spotLocales = [SpotLocale]()
    
    let locationManager = CLLocationManager()

    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var directionButton: UIButton!
    
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!

    }
    
    
    @IBAction func showCurrentLocation(_ sender: UIButton) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let currRegion = MKCoordinateRegion(center: currentCoordinate, span: span)
        
        map.setRegion(currRegion, animated: true)
    }
    
    @IBAction func showSpotLocation(_ sender: UIButton) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let startRegion = MKCoordinateRegion(center: spotCoordinate!, span: span)
        map.setRegion(startRegion, animated: true)
    }
    
    @IBAction func saveSpot(_ sender: UIBarButtonItem) {
        
        //send all relevant data to firebase to store as new spot
//        let savedSpot = SpotLocale(coord: spotCoordinate!, named: "NoNameYet", detail: "N/A")
//        
//        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "findSpotVC") as! FindSpotViewController
//        destVC.addSpot(newSpot: savedSpot)
//        self.present(destVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func getDirections(_ sender: UIButton) {
        
        let currentPlacemark = MKPlacemark(coordinate: currentCoordinate)
        let spotPlacemark = MKPlacemark(coordinate: spotCoordinate!)
        
        //make a mapIdtem from placemarks
        let currentMapItem = MKMapItem(placemark: currentPlacemark)
        let spotMapItem = MKMapItem(placemark: spotPlacemark)
        
        //create array of map items [from, to]
        let mapItems = [currentMapItem,spotMapItem]
        
        let directionOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        //get directions from Map Application
        MKMapItem.openMaps(with: mapItems, launchOptions: directionOptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        giveButtonEffects(button: directionButton)
        map.layer.cornerRadius = 5
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = 5

        
        self.map.showsUserLocation = true
        // get locations and place annotations on map
        gatherLocales()
        placeAnnotations()
        configureLocationManager()
        //zoom map to include all annotations
        self.map.showAnnotations(self.spotLocales, animated: true)


    }
    
    //MARK: Location Manager functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //set current location
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        currentCoordinate.latitude = locValue.latitude
//        currentCoordinate.longitude = locValue.longitude
        print("currlocations = \(locValue.latitude) \(locValue.longitude)")
        

    }
    
    //MARK: MapView Function
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //
        if (annotation.subtitle! == "Spot HQ") {
            
            // Better to make this class property
            let annotationIdentifier = "AnnotationIdentifier"
            
            var annotationView: MKAnnotationView?
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            }
            else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            
            if let annotationView = annotationView {
                // Configure your annotation view here
                annotationView.canShowCallout = true
                let resizedImage = imageResize(image: spotImage!, sizeChange: CGSize(width: 50, height: 50))
                annotationView.image = resizedImage
            }
            
            return annotationView
        }
        
        if (annotation.subtitle! == "Current HQ") {
            let pinView = MKPinAnnotationView()
            pinView.pinTintColor = .green
            pinView.canShowCallout = true
            return pinView
        }
        
        return nil
    }
    
    //NARK: Private Functions
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func gatherLocales() {
        
        let currCoord = SpotLocale(coord: currentCoordinate, named: "Current Location", detail: "Current HQ")
        let spotCoord = SpotLocale(coord: spotCoordinate!, named: "Parking Spot", detail: "Spot HQ")
        spotLocales.append(currCoord)
        spotLocales.append(spotCoord)
    }
    
    func placeAnnotations() {
        map.addAnnotations(spotLocales)
    }
    
    func midpoint(currLoc: CLLocationCoordinate2D, DestLoc: CLLocationCoordinate2D, per: Double) -> (Double, Double) {
        return (currLoc.latitude + (DestLoc.latitude - currLoc.latitude) * per, currLoc.longitude + (DestLoc.longitude - currLoc.longitude) * per);
    }
    
    //resize a UIImage for use on the map
    func imageResize (image: UIImage, sizeChange: CGSize) -> UIImage {
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))

        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func giveButtonEffects(button: UIButton) {
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = 5
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "saveSegue" {
            let savedSpot = SpotLocale(coord: spotCoordinate!, named: "NoNameYet", detail: "N/A")

            let destVC = segue.destination as? FindSpotViewController
            
            destVC?.savedSpot = savedSpot
            
        }
        
    }
    

}
