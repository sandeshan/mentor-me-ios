//
//  ClassTableViewCell.swift
//  Mentor.me
//
//  Created by user135673 on 4/24/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {

    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
