//
//  ClassDetailsViewController.swift
//  Mentor.me
//
//  Created by user135673 on 4/26/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import GooglePlaces
import GoogleMaps
import Toast_Swift

class ClassDetailsViewController: UIViewController {
    
    var databaseRef: DatabaseReference!
    var placesClient: GMSPlacesClient!
    
    var teaching: Bool = false
    
    var classDetails: ClassModel!
    var teacherDetails: UserModel!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classDesc: UILabel!
    
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherPhoneNum: UIButton!
    @IBOutlet weak var teacherAddress: UIButton!
    var placeDetails: GMSPlace!
    
    var userInterested: Bool!
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var teacherActions: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser?.uid
        self.databaseRef = Database.database().reference()
        self.placesClient = GMSPlacesClient()
        
        Alamofire.request(self.classDetails.picture!).responseImage { response in
            
            if let image = response.result.value {
                self.classImage.image = image
            }
        }

        self.classTitle.text = self.classDetails.title
        self.classDesc.text = self.classDetails.description
        
        self.databaseRef.child("users").child(self.classDetails.teacherID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let address = value?["address"] as! NSDictionary
            
            self.teacherDetails = UserModel(id: self.classDetails.teacherID!,
                                 fullName: value?["fullName"] as? String ?? "",
                                 phoneNum: value?["phoneNum"] as? String ?? "",
                                 profileImage: value?["profileImage"] as? String ?? "",
                                 formattedAddress: address["formattedAddress"] as? String ?? "",
                                 placeID: address["placeID"] as? String ?? "")
            
            self.showTeacherDetails(teacher: self.teacherDetails)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if (self.teaching) {
            self.actionBtn.setTitle("Edit Class", for: .normal)
        } else {
            self.teacherActions.removeFromSuperview()
            if (self.classDetails.interested != nil) {
                self.userInterested = (self.classDetails.interested![userID!] != nil)
                self.setInterested(type: self.userInterested)
            } else {
                self.userInterested = false
                self.setInterested(type: false)
            }
        }
        
    }
    
    func showTeacherDetails(teacher: UserModel) {
        self.teacherName.text = teacher.fullName
        
        Alamofire.request(teacher.profileImage!).responseImage { response in
            
            if let image = response.result.value {
                self.teacherImage.image = image
            }
        }
        self.teacherPhoneNum.setTitle(teacher.phoneNum, for: .normal)
        
        placesClient.lookUpPlaceID(self.classDetails.location!, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            guard let place = place else {
                print("No place details for \(self.classDetails.location!)")
                return
            }
            self.placeDetails = place
            if (self.teaching) {
                self.teacherAddress.setTitle(place.formattedAddress, for: .normal)
            } else {
                self.teacherAddress.setTitle("\(self.classDetails.distance!) away", for: .normal)
            }
        })
    }

    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MapViewController
        {
            let vc = segue.destination as? MapViewController
            vc?.placeDetails = self.placeDetails
        }
        
        if segue.destination is UsersViewController
        {
            let vc = segue.destination as? UsersViewController
            var users = [String]()
            if (self.classDetails.interested != nil) {
                for pair in self.classDetails.interested! {
                    users.append(pair.key)
                }
            }
            vc?.userIDs = users
        }
    }
    
    @IBAction func phoneNumClicked(_ sender: UIButton) {
        guard let number = URL(string: "tel://" + self.teacherDetails.phoneNum!) else { return }
        UIApplication.shared.open(number)
    }
    
    func setInterested(type: Bool) {
        if (type) {
            self.actionBtn.setTitle("Not Interested", for: .normal)
            self.actionBtn.backgroundColor = UIColor.red
        } else {
            self.actionBtn.setTitle("I'm Interested !", for: .normal)
            self.actionBtn.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func actionBtnClick(_ sender: UIButton) {
        
        if (self.teaching) {
            let storyboard = UIStoryboard(name: "AddClass", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "addClass") as! AddClassViewController
            controller.edit = true
            controller.classDetails = self.classDetails
            controller.interested = self.classDetails.interested!
            self.present(controller, animated: true, completion: nil)
        } else {
            let userID = Auth.auth().currentUser?.uid
            
            if (self.userInterested) {
                self.view.makeToast("Removed from your Classes !", position: .center)
                self.databaseRef.child("classes").child(self.classDetails.id!)
                    .child("interested").child(userID!).removeValue()
            } else {
                self.view.makeToast("Added to your Classes !", position: .center)
                self.databaseRef.child("classes").child(self.classDetails.id!)
                    .child("interested").child(userID!).setValue(true)
            }
            self.userInterested = !self.userInterested
            self.setInterested(type: self.userInterested)
        }
    }
    
    @IBAction func deleteClicked(_ sender: UIButton) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Delete Class", message: "Are you sure you want to Delete this Class ?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.deleteClass(id: self.classDetails.id!)
            alertController.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteClass(id: String) {
        self.databaseRef.child("classes").child(id).removeValue()
        self.view.makeToast("Class Deleted !", position: .center)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
