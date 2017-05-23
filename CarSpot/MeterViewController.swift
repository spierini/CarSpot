//
//  MeterViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 4/30/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit



class MeterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UNUserNotificationCenterDelegate {
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmLabel: UILabel!
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    
    var hours = ["0", "1", "2"]
    var minutes = ["0"]
    var numSeconds = 0
    var timer : Timer?
    var isGrantedNotificationAccess:Bool = false
    
    //picture, name, and location saved in previous ViewController
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
    

    
    //when pressing the start button
    @IBAction func startTimer(_ sender: UIButton) {
        
        //get number of seconds from the hour/minute pickerview selection
        numSeconds = (pickerView.selectedRow(inComponent: 0) * 3600) + (pickerView.selectedRow(inComponent: 1) * 60)
        // perform action function every 1.0 time interval
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: numSeconds)
        timerLabel.text = "\(timeText(h)):\(timeText(m)):\(timeText(s))"
        
        
        
        startButton.isEnabled = false//startButton.isHidden = true
        stopButton.isEnabled = true//stopButton.isHidden = false
        
        pickerView.isHidden = true
        hourLabel.isHidden = true
        minLabel.isHidden = true
        timerLabel.isHidden = false
        
    }
    
    //when pressig the stop button
    @IBAction func stopTimer(_ sender: UIButton) {
        
        numSeconds = 0
        timer!.invalidate()
        timerLabel.text = "00:00:00"
        
        startButton.isEnabled = true//startButton.isHidden = false
        stopButton.isEnabled = false//stopButton.isHidden = true

        pickerView.isHidden = false
        hourLabel.isHidden = false
        minLabel.isHidden = false
        timerLabel.isHidden = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fillData()
        //set up initial UI look
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
    
    // MARK: - UIPickerViewDataSource Methods (both required)
    
    // return number of columns/wheels
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        }
        else if component == 1 {
            return minutes.count
        }
        
        return 0
    }
    
    // MARK: - UIPickerViewDelegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return hours[row]
        }
        else if component == 1 {
            return minutes[row]
        }
        
        return "!!!"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    // MARK: - Private methods
    func fillData() {
        for index in 1...59 {
            minutes.append(String(index))
        }
        
        for index in 3...23 {
            hours.append(String(index))
        }
    }
    
    //provide initial setup for UI
    func initInterface() {
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        startButton.clipsToBounds = true
        stopButton.layer.cornerRadius = 0.5 * startButton.bounds.size.width
        stopButton.clipsToBounds = true
        
        stopButton.isEnabled = false //stopButton.isHidden = true
        timerLabel.isHidden = true
        
        
    }
    
    //action function for timer
    func updateTimer() {
        
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: numSeconds)
        
        timerLabel.text = "\(timeText(h)):\(timeText(m)):\(timeText(s))"
        
        if(numSeconds == 60 && alarmSwitch.isOn) {
            meterNotif()
        }
        if(numSeconds == 0 && alarmSwitch.isOn) {
            meterAlarm()
            timer!.invalidate()

        }
        
        if(numSeconds > 0) {
            numSeconds -= 1
        }
        
        
    }
    
    func meterAlarm() {
        //is an alert controller
        let alert = UIAlertController(title: "Alert", message: "Your meter is out of time.", preferredStyle: .alert)
        //define actions using callbacks (this is information going to pass you "alert:UIAlertAction" will be that type and return void)
        let defaultAction = UIAlertAction(title: "OK", style: .default) {
            //closure is third argument that is between brackets
            (alert: UIAlertAction!) -> Void in
            print("You pressed button OK")
        }
        
        //associate alert with the controller action
        alert.addAction(defaultAction)
        
        // PRESENT it to the view controller storyboard
        present(alert, animated: true, completion:nil) //nil param stands for i want to do something once view has become visible
    }
    
    //set up  meter notification
    func meterNotif() {
        if isGrantedNotificationAccess{
            //add notification code here
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Meter Time Reminder"
            content.subtitle = "1 Minute Remaining."
            content.body = "The time on your meter spot is low. Please return to your vehicle."
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
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mapSegue" {
            let navVC = segue.destination as? UINavigationController
            let destinationVC = navVC?.viewControllers.first as! MapViewController
            
            destinationVC.spotImage = photoTaken
            destinationVC.spotCoordinate = currLoc
            destinationVC.spotName = spotName
            
        }
        
    }
 

}
