//
//  MapViewController.swift
//  Mentor.me
//
//  Created by Sandesh Ashok Naik on 5/1/18.
//  Copyright © 2018 SandeshNaik. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    var placeDetails: GMSPlace!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: self.placeDetails.coordinate.latitude, longitude: self.placeDetails.coordinate.longitude, zoom: 12.0)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.placeDetails.coordinate.latitude, longitude: self.placeDetails.coordinate.longitude)
        marker.title = self.placeDetails.name
        marker.snippet = self.placeDetails.formattedAddress
        marker.map = self.mapView
        
        self.mapView.camera = camera
        
    }

    @IBAction func doneClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
