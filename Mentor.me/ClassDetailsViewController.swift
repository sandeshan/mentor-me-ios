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
import Toast_Swift

class ClassDetailsViewController: UIViewController {
    
    var databaseRef: DatabaseReference!
    
    var classDetails: ClassModel!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classDesc: UILabel!
    
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var teacherPhoneNum: UIButton!
    @IBOutlet weak var teacherAddress: UIButton!
    
    @IBOutlet weak var interestedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.databaseRef = Database.database().reference()
        
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
            
            let user = UserModel(id: self.classDetails.teacherID!,
                                 fullName: value?["fullName"] as? String ?? "",
                                 phoneNum: value?["phoneNum"] as? String ?? "",
                                 profileImage: value?["profileImage"] as? String ?? "",
                                 formattedAddress: address["formattedAddress"] as? String ?? "",
                                 placeID: address["placeID"] as? String ?? "")
            
            self.showTeacherDetails(teacher: user)
            
        }) { (error) in
            print(error.localizedDescription)
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
        self.teacherAddress.setTitle(teacher.formattedAddres, for: .normal)
    }

    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func interestedBtnClick(_ sender: UIButton) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
