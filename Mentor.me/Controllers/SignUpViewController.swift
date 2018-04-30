//
//  SignUpViewController.swift
//  FirebaseTutorial
//
//  Created by user135673 on 4/20/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != nil {
                // User is signed in.
                let viewController:UIViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeView") as UIViewController
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    //Sign Up Action for email
    @IBAction func createAccountAction(_ sender: AnyObject) {
        if emailTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username

                    let viewController:UIViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeView") as UIViewController
                    self.present(viewController, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
}

