//
//  UsersViewController.swift
//  Mentor.me
//
//  Created by Sandesh Ashok Naik on 5/2/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var usersTable: UITableView!
    
    var userIDs = [String]()
    var usersArray = [UserModel]()
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchUsers()
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers() {
        
        for userID in self.userIDs {
            self.databaseRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let address = value?["address"] as! NSDictionary
                
                let user = UserModel(id: userID,
                                     fullName: value?["fullName"] as? String ?? "",
                                     phoneNum: value?["phoneNum"] as? String ?? "",
                                     profileImage: value?["profileImage"] as? String ?? "",
                                     formattedAddress: address["formattedAddress"] as? String ?? "",
                                     placeID: address["placeID"] as? String ?? "")
                
                self.usersArray.append(user)
                self.usersTable.reloadData()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! UserTableViewCell
        
        if (self.usersArray.count > 0) {
            
            let user = self.usersArray[indexPath.row]
            
            cell.nameLabel.text = user.fullName
            cell.phoneNumBtn.setTitle("Phone: \(user.phoneNum!)", for: .normal)
            
            Alamofire.request(user.profileImage!).responseImage { response in
                
                if let image = response.result.value {
                    cell.userImage.image = image
                }
            }
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
