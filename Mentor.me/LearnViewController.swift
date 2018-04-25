//
//  LearnViewController.swift
//  Mentor.me
//
//  Created by user135673 on 4/24/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import DropDown

class LearnViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var classesList: UITableView!
    
    var classesArray = [ClassModel]()
    var categoriesArray = [CategoryModel]()
    
    var databaseRef: DatabaseReference!
    
    var dropDown: DropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("test")
        
        databaseRef = Database.database().reference()
        initDropdown()
        fetchClasses()
    }
    
    func initDropdown() {
        self.dropDown = DropDown()
        self.dropDown.anchorView = categoryBtn
        
        self.databaseRef.child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.categoriesArray.removeAll()
                for categories in snapshot.children.allObjects as! [DataSnapshot] {
                    let categoryObj = categories.value as? [String: AnyObject]
                    
                    let cat = CategoryModel(categoryID: categoryObj?["id"] as? Int,
                                            categoryName: categoryObj?["name"] as? String)
                    
                    self.categoriesArray.append(cat)
                }
                for category in self.categoriesArray {
                    self.dropDown.dataSource.append(category.categoryName!)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func categoryBtnClick(_ sender: UIButton) {
        self.dropDown.show()
    }
    
    func fetchClasses() {
//        let userID = Auth.auth().currentUser?.uid
        self.databaseRef.child("classes").observe( .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.classesArray.removeAll()
                for classes in snapshot.children.allObjects as! [DataSnapshot] {
                    let classObj = classes.value as? [String: AnyObject]
                    
                    let eachClass = ClassModel(category: classObj?["category"] as? Int,
                                               description: classObj?["description"] as? String,
                                               location: classObj?["location"] as? String,
                                               picture: classObj?["picture"] as? String,
                                               teacherID: classObj?["teacherID"] as? String,
                                               title: classObj?["title"] as? String)
                    
                    self.classesArray.append(eachClass)
                }
                self.classesList.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
        
        let details = self.classesArray[indexPath.row]
        
        cell.classTitle.text = details.title
        cell.classDesc.text = details.description
        
        Alamofire.request(details.picture!).responseImage { response in
            
            if let image = response.result.value {
                cell.classImage.image = image
            }
        }
        
        return cell
    }

}
