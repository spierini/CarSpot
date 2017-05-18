//
//  ViewController.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 4/25/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        
        //perform the segue
        self.performSegue(withIdentifier: "setSpotSegue", sender: nil)

    }
    
    
    @IBAction func setSpotUnwind(segue : UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        giveButtonEffects(button: setButton)
        giveButtonEffects(button: findButton)

        
    }
    
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

