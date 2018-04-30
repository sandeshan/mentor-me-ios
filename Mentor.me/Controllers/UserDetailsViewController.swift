//
//  UserDetailsViewController.swift
//  Mentor.me
//
//  Created by user135673 on 4/21/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker
import GooglePlaces
import GooglePlacePicker
import Toast_Swift

class UserDetailsViewController: UIViewController, ImagePickerDelegate, GMSPlacePickerViewControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    var fullName: String!
    var phoneNum: String!
    var formattedAddress: String!
    
    @IBOutlet weak var selectAddressBtn: UIButton!
    
    @IBOutlet weak var exitBtn: UIButton!
    
    var databaseRef: DatabaseReference!
    
    var imagePickerController: ImagePickerController!
    var imageURL: String = "https://firebasestorage.googleapis.com/v0/b/mentor-me-ios.appspot.com/o/profile-pictures%2Fdefault_user_img.png?alt=media&token=3bd52252-85e8-4b9c-ad82-15b29264267d"
    
    var imagePicked: Bool = false
    
    var placePicker: GMSPlacePickerViewController!
    var placeID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        nameField.text = self.fullName
        phoneField.text = self.phoneNum
        addressField.text = self.formattedAddress
    }
    
    
    @IBAction func exitClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        
        self.databaseRef.child("users").child(Auth.auth().currentUser!.uid).setValue([
            "fullName": String(nameField.text ?? ""),
            "phoneNum": String(phoneField.text ?? ""),
            "address": ["placeID": self.placeID, "formattedAddress": String(addressField.text ?? "")],
            "profileImage": imageURL
            ])
        
        self.view.makeToast("Profile Updated!")
    }
    
    @IBAction func selectAddressClicked(_ sender: UIButton) {
        
        let config = GMSPlacePickerConfig(viewport: nil)
        placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
        
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place id: \(place.placeID)")
        
        self.placeID = place.placeID
        self.addressField.text = place.formattedAddress
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    @IBAction func uploadClicked(_ sender: UIButton) {
        
        var config = Configuration()
        config.allowMultiplePhotoSelection = false
        imagePickerController = ImagePickerController(configuration: config)
        
        imagePickerController.imageLimit = 1
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let resizedImage = self.resizeImage(image: images[0], targetSize: CGSize(width: 200.0, height: 200.0))
        
        let optimizedImageData = UIImageJPEGRepresentation(resizedImage, 0.6)
        self.userImage.image = resizedImage
        self.uploadImage(imageData: optimizedImageData!)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let resizedImage = self.resizeImage(image: images[0], targetSize: CGSize(width: 200.0, height: 200.0))
        
        let optimizedImageData = UIImageJPEGRepresentation(resizedImage, 0.6)
        self.userImage.image = resizedImage
        self.uploadImage(imageData: optimizedImageData!)
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(imageData: Data) {
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("profile-pictures").child("\(currentUser!.uid).jpg")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            
            if error != nil {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                self.imagePicked = true
                self.imageURL = (uploadedImageMeta?.downloadURL()?.absoluteString)!
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
