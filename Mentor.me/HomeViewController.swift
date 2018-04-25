//
//  HomeTabsController.swift
//  Mentor.me
//
//  Created by user135673 on 4/23/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UITabBarController {
    
    var databaseRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        self.checkDetails()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDetails() {
        databaseRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let userID = Auth.auth().currentUser?.uid
            
            if !(snapshot.hasChild(userID!)) {
                let viewController:UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "Details") as UIViewController
                self.present(viewController, animated: true, completion: nil)
            }            
        })
    }
    

    @IBAction func logOutAction(sender: AnyObject) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

}
