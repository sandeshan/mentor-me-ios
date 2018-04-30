//
//  UserModel.swift
//  Mentor.me
//
//  Created by user135673 on 4/26/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import Foundation

class UserModel {
    let id: String?
    let fullName: String?
    let phoneNum: String?
    let profileImage: String?
    let formattedAddres: String?
    let placeID: String?
    
    init(id: String?, fullName: String?, phoneNum: String?, profileImage: String?, formattedAddress: String?, placeID: String?) {
        self.id = id
        self.fullName = fullName
        self.phoneNum = phoneNum
        self.profileImage = profileImage
        self.formattedAddres = formattedAddress
        self.placeID = placeID
    }
}
