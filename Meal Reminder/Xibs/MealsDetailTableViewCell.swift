//
//  MealsDetailTableViewCell.swift
//  Meal Reminder
//
//  Created by Karanbir Singh on 23/10/18.
//  Copyright © 2018 NA. All rights reserved.
//

import UIKit

class MealsDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
