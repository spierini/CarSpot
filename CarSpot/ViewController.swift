//
//  ViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 4/25/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ViewController: UIViewController {

    // You can combine this with the init but not in the 1st VC
    var spotRoot : FIRDatabaseReference?
    
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    
    // MARK: IBAction functions
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        
        //perform the segue
        self.performSegue(withIdentifier: "setSpotSegue", sender: nil)

    }
    
    
    @IBAction func setSpotUnwind(segue : UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This must precede getting the database reference
        FIRDatabase.database().persistenceEnabled = true
        spotRoot = FIRDatabase.database().reference(withPath: "ParkingSpots")
        
//        let garage1 = SpotLocale(coord: CLLocationCoordinate2D(latitude: 35.278882, longitude:  -120.661616), named: "1260 Chorro St Garage", detail: "high impact")
//        let g1Ref = spotRoot?.child(garage1.title!)
//        g1Ref?.setValue(garage1.toAnyObject())
//        
//        let garage2 = SpotLocale(coord: CLLocationCoordinate2D(latitude: 35.281721, longitude:  -120.664026), named: "812 Palm St Garage", detail: "low impact")
//        let g2Ref = spotRoot?.child(garage2.title!)
//        g2Ref?.setValue(garage2.toAnyObject())
//
//        let garage3 = SpotLocale(coord: CLLocationCoordinate2D(latitude: 35.282253, longitude:  -120.662957), named: "Public Works Garage", detail: "medium impact")
//        let g3Ref = spotRoot?.child(garage3.title!)
//        g3Ref?.setValue(garage3.toAnyObject())
        

        // Do any additional setup after loading the view, typically from a nib.
        giveButtonEffects(button: setButton)
        giveButtonEffects(button: findButton)

        
    }
    
    
    // MARK: Private functions
    
    func giveButtonEffects(button: UIButton) {
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

