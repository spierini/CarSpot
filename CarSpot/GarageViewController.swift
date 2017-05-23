//
//  GarageViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/9/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit


class GarageViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var findCarButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceLimitLabel: UILabel!
    @IBOutlet weak var priceStepper: UIStepper!
    @IBOutlet weak var currPriceLabel: UILabel!
    
    var numSeconds = 0
    var currPPHour = 0.75
    var priceLimit = 0.00
    var currPrice = 0.00
    var timer : Timer?
    
    var isGrantedNotificationAccess:Bool = false
    
    //picture, name, and location saved at time of parking
    var photoTaken: UIImage?
    var currLoc: CLLocationCoordinate2D?
    var spotName: String?
    
    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        initInterface()
        
        //request notification permission
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
            }
        )
        
        //assign it a delegate to post notification in foreground
        UNUserNotificationCenter.current().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        
        //numSeconds = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: numSeconds)
        timerLabel.text = "\(timeText(h)):\(timeText(m)):\(timeText(s))"
        
        
        
        startButton.isEnabled = false//startButton.isHidden = true
        stopButton.isEnabled = true//stopButton.isHidden = false
        priceSlider.isEnabled = false
        priceStepper.isEnabled = false
    }

    @IBAction func stopTimer(_ sender: UIButton) {
        numSeconds = 0
        timer!.invalidate()
        timerLabel.text = "00:00:00"
        
        startButton.isEnabled = true//startButton.isHidden = false
        stopButton.isEnabled = false//stopButton.isHidden = true
        priceSlider.isEnabled = true
        priceStepper.isEnabled = true

    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        currPPHour = round(Double(priceSlider.value) * 100)/100
        priceLabel.text = "$" + moneyText(currPPHour)
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        priceLimit = round(100*(currPPHour * sender.value))/100
        print(priceLimit)
        priceLimitLabel.text = "$" + moneyText(currPPHour * sender.value)
    }
    
    //provide initial setup for UI
    func initInterface() {
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true
        startButton.layer.shadowColor = UIColor.darkGray.cgColor
        startButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        startButton.layer.shadowOpacity = 1.0
        startButton.layer.shadowRadius = 5
        
        stopButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        stopButton.clipsToBounds = true
        stopButton.layer.shadowColor = UIColor.darkGray.cgColor
        stopButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        stopButton.layer.shadowOpacity = 1.0
        stopButton.layer.shadowRadius = 2
        
        giveButtonEffects(button: findCarButton)
        
        stopButton.isEnabled = false //stopButton.isHidden = true
        
    }
    
    //action function for timer
    func updateTimer() {
        
        numSeconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: numSeconds)
        timerLabel.text = "\(timeText(h)):\(timeText(m)):\(timeText(s))"
        
        let hourMod = numSeconds%3600
        let numHours = numSeconds/3600 // 5
        currPrice = round(Double(numHours)*currPPHour*100)/100
        
        if(currPrice == priceLimit && alarmSwitch.isOn == true) {
            print("got to limit")
            garageNotif()
            garageAlarm()
            
        }
        
        //every hour update current price label
        if(hourMod == 0) { //(numSeconds == 5){
            currPriceLabel.text = "$" + moneyText(currPrice)

        }
        
    }
    
    func garageAlarm() {
        //is an alert controller
        let alert = UIAlertController(title: "Alert", message: "Your garage cost limit has been reached.", preferredStyle: .alert)
        //define actions using callbacks (this is information going to pass you "alert:UIAlertAction" will be that type and return void)
        let defaultAction = UIAlertAction(title: "OK", style: .default) {
            //closure is third argument that is between brackets
            (alert: UIAlertAction!) -> Void in
            print("You pressed button OK")
            self.timer!.invalidate()

        }
        
        //associate alert with the controller action
        alert.addAction(defaultAction)
        
        // PRESENT it to the view controller storyboard
        present(alert, animated: true, completion:nil) //nil param stands for i want to do something once view has become visible
    }
    
    //set up  garage notification
    func garageNotif() {
        if isGrantedNotificationAccess{
            //add notification code here
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Garage Cost Reminder"
            content.subtitle = "Cost Limit Reached."
            content.body = "The cost on your garage spot has been reached. Please return to your vehicle."
            content.sound = UNNotificationSound.default()
            
            
            //Set the trigger of the notification -- here a timer.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(identifier: "1.second.message", content: content, trigger: trigger)
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }
    }
    
    //convert seconds into a h,m,s 3 value tuple
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //add leading 0's to string integers that need it
    func timeText(_ s: Int) -> String {
        return s < 10 ? "0\(s)" : "\(s)"
    }
    
    //round to the nearest 100th place and convert to a string
    func moneyText(_ s: Double) -> String {
        
        return String(round(100*s)/100)
    }
    
    // create dropshadows and rounded edges for buttons
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
        
        if segue.identifier == "mapSegue2" {
            let navVC = segue.destination as? UINavigationController
            let destinationVC = navVC?.viewControllers.first as! MapViewController
            
            destinationVC.spotImage = photoTaken
            destinationVC.spotCoordinate = currLoc
            destinationVC.spotName = spotName

            
        }
        
    }
    

}
