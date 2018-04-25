//
//  ClassModel.swift
//  Mentor.me
//
//  Created by user135673 on 4/24/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import Foundation

class ClassModel {
    
    let category: Int?
    let description: String?
    let location: String?
    let picture: String?
    let teacherID: String?
    let title: String?
    
    init(category: Int?, description: String?, location: String?, picture: String?, teacherID: String?, title: String?) {
        self.category = category
        self.description = description
        self.location = location
        self.picture = picture
        self.teacherID = teacherID
        self.title = title
    }
}
