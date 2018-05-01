//
//  ClassModel.swift
//  Mentor.me
//
//  Created by user135673 on 4/24/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import Foundation

class ClassModel {
    
    let id: String?
    let category: Int?
    let description: String?
    let location: String?
    var distance: String?
    let picture: String?
    let teacherID: String?
    let title: String?
    let interested: [String : Bool]?
    
    init(id: String?, category: Int?, description: String?, location: String?, distance: String?, picture: String?, teacherID: String?, title: String?, interested: [String : Bool]?) {
        self.id = id
        self.category = category
        self.description = description
        self.location = location
        self.distance = distance
        self.picture = picture
        self.teacherID = teacherID
        self.title = title
        self.interested = interested
    }
}
