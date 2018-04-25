//
//  CategoryModel.swift
//  Mentor.me
//
//  Created by user135673 on 4/24/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import Foundation

class CategoryModel {
    let categoryID: Int?
    let categoryName : String?
    
    init(categoryID: Int?, categoryName: String?) {
        self.categoryID = categoryID
        self.categoryName = categoryName
    }
    
}
