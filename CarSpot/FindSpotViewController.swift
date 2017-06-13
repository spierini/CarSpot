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
    @IBOutlet weak var directionButton: UIButton!
    
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

        //create an 'edit' barbuttonitem with an action to allow for editing
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editObjects(_:)))
        //set the button to be on the left side
        self.navigationItem.rightBarButtonItem = editButton
        
        spotTableView.rowHeight = 80
        spotTableView.layer.cornerRadius = 5
        spotTableView.showsVerticalScrollIndicator = false
        
        containerView.backgroundColor = UIColor.clear
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = 5
        
        giveButtonEffects(button: directionButton)
        
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
        
        self.map.showsUserLocation = true

    }
    
    func setRetrieveCallback() {
        spotRoot?.queryOrdered(byChild: "ParkingSpots").observeSingleEvent(of: .value, with:
            { snapshot in
                
                print("In here")
                var newSpots = [SpotLocale]()
                
                //add (optional) saved spot to Firebase
                let addedSpot = self.addSavedSpot(newSpot: self.savedSpot)
                
                for item in snapshot.children {
                    newSpots.append(SpotLocale(snapshot: item as! FIRDataSnapshot))
                }
                // append saved spot to data array before reloading table
                if(addedSpot != nil){ newSpots.append(addedSpot!) }
                
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
    func addSavedSpot(newSpot : SpotLocale?) -> SpotLocale? {
        
        if(newSpot != nil) {
            // add to Firebase
            let newSpotRef = spotRoot?.child((newSpot?.title!)!)
            newSpotRef?.setValue(newSpot?.toAnyObject())
            return newSpot
        }
        else {
            print("No saved spot added")
            return nil
        }
        
    }
    
    // create dropshadows and rounded edges for buttons
    func giveButtonEffects(button: UIButton) {
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = 5
    }
    
    // called when 'done' button was pressed
    func doneEditing(_ sender: AnyObject) {
        
        //create 'edit' button again with same action
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editObjects(_:)))
        self.navigationItem.rightBarButtonItem = editButton
        //make editing impossible again
        self.spotTableView.setEditing(false, animated: true)
        
    }
    
    // called when 'edit' button was pressed
    func editObjects(_ sender: AnyObject) {
        
        //make editing possible
        self.spotTableView.setEditing(true, animated: true)
        //create a temporary 'done' button with an action to end editing
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditing(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    //remove movie from selected list given it's key
    func removeFromFirebase(spotTitle : String) {

        spotRoot?.child(spotTitle).removeValue()

        
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
        cell?.traffic.textColor = getTrafficColor(trafficString: (cell?.traffic.text)!)
        cell?.coordinate.text = "\(thisSpot.latitude)\n\(thisSpot.longitude)"
        
        if(thisSpot.subtitle == "N/A") {
            cell?.photo.image = UIImage(named: "meter")
        }
        else {
            cell?.photo.image = UIImage(named: "parking")

        }
        
        return cell!
        
    }
    
    
    // Callback if table row was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let thisSpot = spotData[indexPath.row]
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let startRegion = MKCoordinateRegion(center: thisSpot.coordinate, span: span)
        self.map.setRegion(startRegion, animated: true)
        self.map.selectAnnotation(thisSpot, animated: true)
        
        spotLocation = thisSpot.coordinate
        
    }
    
    // support editing the table view. called when "delete" is clicked
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //so the firebase entry doesnt get added as it is deleted****
            savedSpot = nil
            map.removeAnnotation(spotData[indexPath.row])
            let spotToRemove = spotData[indexPath.row].title!
            
            // Delete the row from the data source
            spotData.remove(at: indexPath.row)
            removeFromFirebase(spotTitle: spotToRemove)
            print("Before viewDidLoad?")
            tableView.deleteRows(at: [indexPath], with: .fade)
//            map.reloadInputViews()


            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let thisSpot = spotData[indexPath.row]
    
        
        //give alert so user can choose availability for garage (low med high)
        let alert = UIAlertController(title: "Traffic Feedback", message: "Select Parking Garage Traffic Level",
                                      preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: "Low", style: .default) {
            (alert: UIAlertAction!) -> Void in
            
            thisSpot.subtitle = "low impact"
            //update Firebase based on title of the spotData
            self.spotRoot?.child(self.spotData[indexPath.row].title!).child("traffic").setValue(thisSpot.subtitle)
            //update value in data array
            self.spotData[indexPath.row] = thisSpot
            self.resetReloadAnnot()

            
        }
        let secondAction = UIAlertAction(title: "Medium", style: .default) {
            (alert: UIAlertAction!) -> Void in
            
            thisSpot.subtitle = "medium impact"
            //update Firebase based on title of the spotData
            self.spotRoot?.child(self.spotData[indexPath.row].title!).child("traffic").setValue(thisSpot.subtitle)
            //update value in data array
            self.spotData[indexPath.row] = thisSpot
            self.resetReloadAnnot()

        }
        let thirdAction = UIAlertAction(title: "High", style: .default) {
            (alert: UIAlertAction!) -> Void in
            
            thisSpot.subtitle = "high impact"
            //update Firebase based on title of the spotData
            self.spotRoot?.child(self.spotData[indexPath.row].title!).child("traffic").setValue(thisSpot.subtitle)
            //update value in data array
            self.spotData[indexPath.row] = thisSpot
            self.resetReloadAnnot()


        }
        
        if(spotData[indexPath.row].subtitle != "N/A") {
            alert.addAction(firstAction)
            alert.addAction(secondAction)
            alert.addAction(thirdAction)
            present(alert, animated: true, completion:nil)
        }
        
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
    
    func resetReloadAnnot() {
        map.removeAnnotations(spotData)
        map.addAnnotations(spotData)
        map.reloadInputViews()
        spotTableView.reloadData()
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
        case "N/A"?:
            //for user saved spots
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
                
                let resizedImage = imageResize(image: UIImage(named: "meter")!, sizeChange: CGSize(width: 50, height: 50))
                annotationView.image = resizedImage
            }
            
            return annotationView
        default:
            return nil
        }
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
    
    //calculate text color based on traffic level string
    func getTrafficColor(trafficString: String) -> UIColor{
        if(trafficString == "low impact") {
            return .green
        }
        else if(trafficString == "medium impact") {
            return .yellow
        }
        else if(trafficString == "high impact") {
            return .red
        }
        else {
            return .black
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

