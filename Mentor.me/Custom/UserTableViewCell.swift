//
//  UserTableViewCell.swift
//  Mentor.me
//
//  Created by Sandesh Ashok Naik on 5/2/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumBtn: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func phoneNumClicked(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + sender.title(for: .normal)!) else { return }
        UIApplication.shared.open(number)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
