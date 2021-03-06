//
//  ContactTableViewCell.swift
//  NxtService
//
//  Created by Emanuel Guerrero
//             Shaquella Dunanson
//             Santago Facuno
//             Jevin Francis
//             Marcus Guerrer
//             Stephen Green
//             Ryan Fernandez on 4/27/16.
//  Copyright © 2016 Project Omicron. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var distance: Int!
    var userAddress: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
    func configureCell(provider: Provider, userLocation: String, distance: Int) {
        self.distance = distance
        self.userAddress = userLocation
        
        if provider.phoneNumber == "" {
            phoneNumberLabel.text = "No number avaliable"
        } else {
            phoneNumberLabel.text = provider.phoneNumber
        }
        
        addressLabel.text = provider.address
    }
}