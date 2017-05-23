//
//  SpotTVCell.swift
//  CarSpot
//
//  Created by Santi Angelo Pierini on 5/20/17.
//  Copyright © 2017 Santi Angelo Pierini. All rights reserved.
//

import UIKit

class SpotTVCell: UITableViewCell {
    
    //name, traffic, lat, long
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var traffic: UILabel!
    @IBOutlet weak var coordinate: UILabel!
    @IBOutlet weak var photo: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
