//
//  PreviousSpotTableViewCell.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-27.
//  Copyright © 2016 Sonny. All rights reserved.
//

import UIKit

class PreviousSpotTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
