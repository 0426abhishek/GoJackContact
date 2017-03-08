//
//  ContactCell.swift
//  Contactbook
//
//  Created by manoj on 01/03/17.
//  Copyright © 2017 get. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

@IBOutlet var ContactImage: UIImageView!

@IBOutlet var StartLetterLabel: UILabel!
@IBOutlet var ContactName: UILabel!
override func awakeFromNib() {
    super.awakeFromNib()
    ContactImage.layer.cornerRadius = ContactImage.frame.height/2
    ContactImage.clipsToBounds = true
    
    StartLetterLabel.layer.cornerRadius = StartLetterLabel.frame.height/2
    StartLetterLabel.clipsToBounds = true
    // Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
}

}
