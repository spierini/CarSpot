//
//  SpotTypeViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 4/30/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class SpotTypeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var parkingMeterButton: UIButton!
    @IBOutlet weak var parkingGarageButton: UIButton!
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var spotName = "Meter Spot"
    
    // MARK: IBAction functions
    
    // meter pressed
    @IBAction func parkingMeter(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "meterSegue", sender: nil)
    }
    
    // garage pressed
    @IBAction func parkingGarage(_ sender: UIButton) {
    }
    
    // MARK: Private Functions
    
    //ask for camera or photo library access
    func giveAlert() {
        let alert = UIAlertController(title: "CarSpot Alert", message: "Do you wish to take or select a photo?",
                                      preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: "Take Photo", style: .default) {
            (alert: UIAlertAction!) -> Void in
            self.takePhoto()
        }
        let secondAction = UIAlertAction(title: "Select Photo", style: .default) {
            (alert: UIAlertAction!) -> Void in
            self.pickImage()
        }
        let thirdAction = UIAlertAction(title: "No Photo", style: .cancel) {
            (alert: UIAlertAction!) -> Void in
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        
        alert.view.center = CGPoint(x: 0, y: 0)
        present(alert, animated: true, completion:nil)
    }
    
    // Grant access to camera and take a photo
    func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            // no camera available
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Grant access to photo library and choose a photo
    func pickImage() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //get the image just taken or chosen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageDisplay.contentMode = .scaleToFill
            imageDisplay.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // create dropshadows and rounded edges for buttons
    func giveButtonEffects(button: UIButton) {
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = 5
    }
    
    //remove dissallowed punctuation from string
    func removeSpecialCharsFromString(text: String) -> String {
        let acceptedChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(text.characters.filter {acceptedChars.contains($0) })
    }
    
    // MARK: Location Manager Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("spotlocations = \(locValue.latitude) \(locValue.longitude)")
        currentLocation.latitude = locValue.latitude
        currentLocation.longitude = locValue.longitude
    }
    



    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        giveButtonEffects(button: parkingMeterButton)
        giveButtonEffects(button: parkingGarageButton)
        
        
        imageDisplay.layer.cornerRadius = 5
        imageDisplay.layer.shadowColor = UIColor.darkGray.cgColor
        imageDisplay.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        imageDisplay.layer.shadowOpacity = 1.0
        imageDisplay.layer.shadowRadius = 2
        
        
        
        giveAlert()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        spotName = removeSpecialCharsFromString(text: nameTextField.text!)
        
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        locationManager.stopUpdatingLocation()

        
        if segue.identifier == "meterSegue" {
            let navVC = segue.destination as? UINavigationController
            let destinationVC = navVC?.viewControllers.first as! MeterViewController
            
            destinationVC.photoTaken = imageDisplay.image
            destinationVC.currLoc = currentLocation
            destinationVC.spotName = spotName
            
        }
        else if(segue.identifier == "garageSegue") {
            let navVC = segue.destination as! UINavigationController
            let destinationVC = navVC.viewControllers.first as! GarageViewController
            
            destinationVC.photoTaken = imageDisplay.image
            destinationVC.currLoc = currentLocation
            destinationVC.spotName = spotName
        }
    }
 

}
