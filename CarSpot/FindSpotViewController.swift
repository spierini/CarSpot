//
//  FindSpotViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/20/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class FindSpotViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var spotRoot : FIRDatabaseReference?
    var spotData = [SpotLocale]()
    
    var savedSpot : SpotLocale?
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var spotLocation : CLLocationCoordinate2D?
    
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!

    }

    
    @IBAction func getDirections(_ sender: UIButton) {
       
        if spotLocation != nil {
//          print(currentLocation)
//          print(spotLocation)
            locationManager.stopUpdatingLocation()
            //open apple maps to get direcitons from currentLocation to spotLocation
            let currentPlacemark = MKPlacemark(coordinate: currentLocation)
            let spotPlacemark = MKPlacemark(coordinate: spotLocation!)
        
            //make a mapIdtem from placemarks
            let currentMapItem = MKMapItem(placemark: currentPlacemark)
            let spotMapItem = MKMapItem(placemark: spotPlacemark)
        
            //create array of map items [from, to]
            let mapItems = [currentMapItem,spotMapItem]
        
            let directionOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            //get directions from Map Application
            MKMapItem.openMaps(with: mapItems, launchOptions: directionOptions)
        }
        else {
            print("Must Pick Spot")
        }
    }

    @IBAction func cancelStop(_ sender: UIBarButtonItem) {
        locationManager.stopUpdatingLocation()
        //call segue
        self.performSegue(withIdentifier: "exitSegue", sender: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        spotTableView.rowHeight = 80
        spotTableView.layer.cornerRadius = 5
        spotTableView.showsVerticalScrollIndicator = false
        
        containerView.backgroundColor = UIColor.clear
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = 5
        
//        FIRDatabase.database().persistenceEnabled = true
        spotRoot = FIRDatabase.database().reference(withPath: "ParkingSpots")
        setRetrieveCallback()
        
        // Ask for Authorisation from the User to get current location
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func setRetrieveCallback() {
        spotRoot?.queryOrdered(byChild: "ParkingSpots").observe(.value, with:
            { snapshot in
                
                var newSpots = [SpotLocale]()
                
                //add saved spot if sent from MapViewController
                self.addSavedSpot(newSpot: self.savedSpot)
                
                for item in snapshot.children {
                    newSpots.append(SpotLocale(snapshot: item as! FIRDataSnapshot))
                }
                
                self.spotData = newSpots
                self.spotTableView.reloadData()
                
                //set annotations/region on main thread after they are recieved
                DispatchQueue.main.async {
                    
                    // let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    // let startRegion = MKCoordinateRegion(center: (self.tacoStands.first?.coordinate)!, span: span)
                    // self.map.setRegion(startRegion, animated: true)
                    self.placeAnnotations()
                    self.map.showAnnotations(self.spotData, animated: true)
                    
                    
                }
        })
    }
    
    // add a saved spot to the database
    func addSavedSpot(newSpot : SpotLocale?) {
        
        if(newSpot != nil) {
//            spotData.append(newSpot!)
            // add to Firebase
            let newSpotRef = spotRoot?.child((newSpot?.title!)!)
            newSpotRef?.setValue(newSpot?.toAnyObject())
        }
        else {
            print("No saved spot added")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source (top 2 are required)
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spotData.count
    }
    
    //set each attribute of the table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //this method uses recycled cells but will create a new one if nothing available (used to be "standardCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as? SpotTVCell
        
        let thisSpot = spotData[indexPath.row]
        
        // Configure the cell...
        cell?.name.text = thisSpot.title
        cell?.traffic.text = thisSpot.subtitle
        cell?.coordinate.text = "\(thisSpot.latitude)\n\(thisSpot.longitude)"
        
        if(thisSpot.subtitle == "N/A") {
            cell?.photo.image = UIImage(named: "meter")
        }
        else {
            cell?.photo.image = UIImage(named: "parking")

        }
        
        return cell!
        
    }
    
    // do something if select a table row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let thisSpot = spotData[indexPath.row]
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let startRegion = MKCoordinateRegion(center: thisSpot.coordinate, span: span)
        self.map.setRegion(startRegion, animated: true)
        
        spotLocation = thisSpot.coordinate
        
    }
    
    // MARK: Location Manager Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("currFindLocation = \(locValue.latitude) \(locValue.longitude)")
        currentLocation.latitude = locValue.latitude
        currentLocation.longitude = locValue.longitude
    }
    

    func placeAnnotations() {
        map.addAnnotations(spotData)
    }
    
    //add the pins based on CSCLocale annotations added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        switch annotation.subtitle! {
        case "low impact"?:
            let pinView = MKPinAnnotationView()
            pinView.pinTintColor = .green
            pinView.canShowCallout = true
            return pinView
            
        case "medium impact"?:
            let pinView = MKPinAnnotationView()
            pinView.pinTintColor = .yellow
            pinView.canShowCallout = true
            return pinView
            
        case "high impact"?:
            let pinView = MKPinAnnotationView()
            pinView.pinTintColor = .red
            pinView.canShowCallout = true
            return pinView
        default:
            //for user saved spots
            let pinView = MKPinAnnotationView()
            pinView.pinTintColor = .blue
            pinView.canShowCallout = true
            return pinView
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
