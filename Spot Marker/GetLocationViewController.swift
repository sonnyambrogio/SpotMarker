//
//  GetLocationViewController.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-21.
//  Copyright © 2016 Sonny. All rights reserved.
//

import UIKit
import MapKit


class GetLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK:- ** Variables **
    var gettingLocation = false
    var lastLocationError: NSError?
    
    var longitude: Double?
    var latitude: Double?
    var location: CLLocation?
    
    var annotationArray = [Annotations]()
    

    
    
    // MARK:- ** Constants **
    let locationManager = CLLocationManager()
    
    let textMessages = TextMessages()
    
    let initialLocation = CLLocation(latitude: 50.088333, longitude: -97.219444)   // Coordinates for the initial Map Location
    
    let regionRadius: CLLocationDistance = 1000     // Amount of Area the Map will show around the given Coordinates
    
    
    // MARK:- ** Life Cycle **
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearAction()
        activityIndicator.hidden = true
        mainButtonOutlet.setTitle(textMessages.getLocation, forState: .Normal)
        
        setInitalMapView(initialLocation)
    }
    
    
    // MARK:- ** Outlets **
    @IBOutlet weak var saveButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var mainButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapview: MKMapView!
    

    // MARK:- ** Actions **
    @IBAction func saveAction() {
    }
    
    
    @IBAction func clearAction() {
        
        stopLocationManager()
        location = nil
        setGetLocationButton()
        updateLabels()
        
        // Check to see if the annotation array is empty.
        // If not, remove the last entry
        if annotationArray.isEmpty == false {
            mapview.removeAnnotation(annotationArray.last!)
        }
        
        setInitalMapView(initialLocation)
        mainButtonOutlet.hidden = false
    }
    
    
    @IBAction func mainButtonAction(sender: UIButton) {
        if gettingLocation {
            clearAction()
        } else if location == nil {
            getLocation()
        } else if location != nil {
            saveAction()
        }
            
        
    }
    
    
    
    // MARK:- ** Functions **
    func setInitalMapView(location: CLLocation) {
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(50, 50)
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, theSpan)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    
    func updateLabels() {
        
        if let location = location {
            
            setSaveButton()
            
            latitudeLabel.hidden = false
            longitudeLabel.hidden = false
            
            latitudeLabel.text = "Latitude: " + String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = "Longitude: " + String(format: "%.8f", location.coordinate.longitude)
            
            clearButtonOutlet.hidden = false
            
            
            centerMapOnLocation(location)
            
            let annotation = Annotations(title:"", coordinate: location.coordinate, info:"")
            annotationArray.append(annotation)
            mapview.addAnnotation(annotationArray.last!)
            
            
        } else {
            
            clearButtonOutlet.hidden = true
            latitudeLabel.hidden = true
            longitudeLabel.hidden = true
        }
    }
    
    
    func stopLocationManager() {
        
        if gettingLocation == true {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            gettingLocation = false
            
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
            
            mainButtonOutlet.setTitle(textMessages.getLocation, forState: .Normal)
            mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonGreen"), forState: .Normal)

            
        }
    }
    
    
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            mainButtonOutlet.setTitle("Stop", forState: .Normal)
            mainButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonRed"), forState: .Normal)
            
            locationManager.startUpdatingLocation()
            
            gettingLocation = true
        }
    }
    
    
    func getLocation() {

        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
    }
    
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: textMessages.locServDisabled, message: "Please enable Location Services for 'Spot Marker' in your Settings App", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: textMessages.ok, style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK:-  ** CLLocationManagerDelegate **
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // 1
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return
        }
        // 2
        if newLocation.horizontalAccuracy < 0 { return
        }
        // 3
        if location == nil ||
            location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // 4
            lastLocationError = nil
            location = newLocation
            
            // 5
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }






}





extension GetLocationViewController {
    func setGetLocationButton() {
        mainButtonOutlet.hidden = false
        mainButtonOutlet.setTitle(textMessages.getLocation, forState: .Normal)
        mainButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonGreen"), forState: .Normal)
    }
    
    func setStopButton() {
        mainButtonOutlet.hidden = false
        mainButtonOutlet.setTitle("Stop", forState: .Normal)
        mainButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonRed"), forState: .Normal)
    }
    
    func setSaveButton() {
        mainButtonOutlet.hidden = false
        mainButtonOutlet.setTitle("Save", forState: .Normal)
        mainButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonYellow"), forState: .Normal)

    }
}










































/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
