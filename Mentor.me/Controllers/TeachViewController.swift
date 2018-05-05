//
//  TeachViewController.swift
//  Mentor.me
//
//  Created by Sandesh Naik on 4/30/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase

class TeachViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var classesList: UITableView!
    
    @IBOutlet weak var addClassBtn: UIButton!
    
    var classesArray = [ClassModel]()
    
    var databaseRef: DatabaseReference!
    let DISTANCE_MATRIX_KEY = "AIzaSyDDG4-J6NDJdHOy-qm_O6m57HJn82Xwk04"
    let DISTANCE_MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
//        self.fetchUserClasses()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchUserClasses()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserClasses() {
        let userID = Auth.auth().currentUser?.uid
        self.databaseRef.child("classes").observe( .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.classesArray.removeAll()
                self.classesList.reloadData()
                for classes in snapshot.children.allObjects as! [DataSnapshot] {
                    let classObj = classes.value as? [String: AnyObject]
                    let interested = classObj!["interested"] as? [String: Bool]
                    
                    let eachClass = ClassModel(id: classes.key,
                                               category: classObj?["category"] as? Int,
                                               description: classObj?["description"] as? String,
                                               location: classObj?["location"] as? String,
                                               distance: "",
                                               picture: classObj?["picture"] as? String,
                                               teacherID: classObj?["teacherID"] as? String,
                                               title: classObj?["title"] as? String, interested: interested)
                    
                    if (eachClass.teacherID == userID) {
                        self.classesArray.append(eachClass)
                        self.classesList.reloadData()
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        let classDetails = self.classesArray[indexPath![1]]
        self.showClassDetails(classDetails: classDetails)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
        
        if (self.classesArray.count > 0) {
            
            let details = self.classesArray[indexPath.row]
            
            cell.classTitle.text = details.title
            cell.classDesc.text = details.description
            
            Alamofire.request(details.picture!).responseImage { response in
                
                if let image = response.result.value {
                    cell.classImage.image = image
                }
            }
        }
        
        return cell
    }
    
    func showClassDetails(classDetails: ClassModel) {
        
        let storyboard = UIStoryboard(name: "ClassDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "classDetails") as! ClassDetailsViewController
        controller.classDetails = classDetails
        controller.teaching = true
        self.present(controller, animated: true, completion: nil)
        
    }

}
