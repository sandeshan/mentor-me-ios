//
//  SettingsController.swift
//  Mentor.me
//
//  Created by user135673 on 4/23/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase

class SettingsController: UITableViewController {
    
    var databaseRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath[1])
        
        if (indexPath[1] == 2) {
            do {
                try Auth.auth().signOut() //authUI!.signOut()
                dismiss(animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UserDetailsViewController
        {
            let vc = segue.destination as? UserDetailsViewController
            let userID = Auth.auth().currentUser?.uid
            databaseRef.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let address = value!["address"] as? NSDictionary
                let imageURL = value?["profileImage"] as? String ?? ""
                
                vc?.nameField.text = value?["fullName"] as? String ?? ""
                vc?.phoneField.text = value?["phoneNum"] as? String ?? ""
                vc?.addressField.text = address?["formattedAddress"] as? String ?? ""
                vc?.placeID = address?["placeID"] as? String ?? ""
                vc?.imageURL = imageURL
                
                Alamofire.request(imageURL).responseImage { response in
                    if let image = response.result.value {
                        vc?.userImage.image = image
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}
