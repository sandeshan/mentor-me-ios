//
//  AddClassViewController.swift
//  Mentor.me
//
//  Created by Sandesh Naik on 4/30/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import Alamofire
import DropDown
import Firebase
import ImagePicker
import GooglePlaces
import GooglePlacePicker
import Toast_Swift

class AddClassViewController: UIViewController, ImagePickerDelegate, GMSPlacePickerViewControllerDelegate {

    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var addImageBtn: UIButton!
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var classTitle: UITextField!
    @IBOutlet weak var classDesc: UITextView!
    
    @IBOutlet weak var categoryBtn: UIButton!
    var dropDown: DropDown!
    var categoriesArray = [CategoryModel]()
    var selectedCategory: Int!
    
    @IBOutlet weak var classLocation: UITextField!
    @IBOutlet weak var selectLocationBtn: UIButton!
    
    @IBOutlet weak var addClassBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var databaseRef: DatabaseReference!
    var placesClient: GMSPlacesClient!
    
    var imagePickerController: ImagePickerController!
    var imageURL: String!
    
    var placePicker: GMSPlacePickerViewController!
    var placeID: String!
    
    var edit: Bool = false
    var classDetails: ClassModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        self.initDropdown()
        placesClient = GMSPlacesClient()
        
        if (self.edit) {
            self.navBar.title = "Edit Class"
            self.classTitle.text = self.classDetails.title
            self.classDesc.text = self.classDetails.description
            self.placeID = self.classDetails.location
            self.imageURL = self.classDetails.picture
            
            Alamofire.request(self.classDetails.picture!).responseImage { response in
                
                if let image = response.result.value {
                    self.classImage.image = image
                }
            }
            
            placesClient.lookUpPlaceID(self.classDetails.location!, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                guard let place = place else {
                    print("No place details for \(self.classDetails.location!)")
                    return
                }
                self.classLocation.text = place.formattedAddress
            })
        }
    }
    
    func initDropdown() {
        self.dropDown = DropDown()
        self.dropDown.anchorView = categoryBtn
        self.dropDown.dismissMode = .automatic
        
        self.databaseRef.child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.categoriesArray.removeAll()
                for categories in snapshot.children.allObjects as! [DataSnapshot] {
                    let categoryObj = categories.value as? [String: AnyObject]
                    
                    let cat = CategoryModel(categoryID: categoryObj?["id"] as? Int,
                                            categoryName: categoryObj?["name"] as? String)
                    
                    self.categoriesArray.append(cat)
                }
                self.categoriesArray.append(CategoryModel(categoryID: 8, categoryName: "All"))
                for category in self.categoriesArray {
                    self.dropDown.dataSource.append(category.categoryName!)
                    
                    if (self.edit && self.classDetails.category == category.categoryID) {
                        self.selectedCategory = self.classDetails.category
                        self.categoryBtn.setTitle("Category: \(category.categoryName!)", for: .normal)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.categoryBtn.setTitle("Category: \(item)", for: .normal)
            self.selectedCategory = index
        }
        
    }
    
    @IBAction func selectCategoryClicked(_ sender: UIButton) {
        self.dropDown.show()
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }    
    
    @IBAction func addImageClicked(_ sender: UIButton) {
        var config = Configuration()
        config.allowMultiplePhotoSelection = false
        imagePickerController = ImagePickerController(configuration: config)
        
        imagePickerController.imageLimit = 1
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func selectLocationClicked(_ sender: UIButton) {
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
        self.classLocation.text = place.formattedAddress
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let image = images[0]
        let optimizedImageData = UIImageJPEGRepresentation(image, 0.6)
        self.classImage.image = image
        self.uploadImage(imageData: optimizedImageData!)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        let image = images[0]
        
        let optimizedImageData = UIImageJPEGRepresentation(image, 0.6)
        self.classImage.image = image
        self.uploadImage(imageData: optimizedImageData!)
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(imageData: Data) {
        let storageReference = Storage.storage().reference()
        let date = NSDate().timeIntervalSince1970
        let profileImageRef = storageReference.child("class-pictures").child("class-\(date).jpg")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            
            if error != nil {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                self.imageURL = (uploadedImageMeta?.downloadURL()?.absoluteString)!
            }
        }
    }
    
    @IBAction func addClassClicked(_ sender: UIButton) {
        let userID = Auth.auth().currentUser!.uid
        var classesRef: DatabaseReference
        
        if (self.edit) {
            classesRef = self.databaseRef.child("classes").child(self.classDetails.id!)
            self.view.makeToast("Class Saved !", position: .center)
        } else {
            classesRef = self.databaseRef.child("classes").childByAutoId()
            self.view.makeToast("Class Added !", position: .center)
        }
        
        classesRef.setValue([
            "category": self.selectedCategory,
            "description": self.classDesc.text ?? "",
            "location": self.placeID,
            "picture": self.imageURL,
            "teacherID": userID,
            "title": self.classTitle.text ?? ""])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   

}
