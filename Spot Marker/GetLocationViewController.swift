//
//  GetLocationViewController.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-21.
//  Copyright © 2016 Sonny. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift


class GetLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK:- ** Variables **
    var gettingLocation = false
    var lastLocationError: NSError?
    var location: CLLocation?
    var spotArray = [FoundSpot]()   // used to create a newly found "Spot" - Might not need to be an arrat=y...Change Later.!
    var previouslySavedSpots = [FoundSpot]()    // uused to create an array of all the previously saved "Spots"
    var titleToSave: String = ""
    var infoToSave: String = ""
    
    // MARK:- ** Constants **
    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude: 50.088333, longitude: -97.219444)   // Coordinates for the initial Map Location
    let regionRadius: CLLocationDistance = 1000     // Amount of Area the Map will show around the given Coordinates
    let realm = try! Realm()
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)   // Get directory of app on device. Used for debugging purposes
    
    
    // MARK:- ** Life Cycle **
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearAction()
        activityIndicator.hidden = true
        print(path)
        
        setInitalMapView(initialLocation)
    }
    

    // MARK:- ** Outlets **
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var mainButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapview: MKMapView!
    

    // MARK:- ** Actions **
    @IBAction func clearAction() {
        
        stopLocationManager()
        location = nil
        setGetLocationButton()
        updateLabels()
        
        // Check to see if the annotation array is empty.
        // If not, remove the last entry
        if spotArray.isEmpty == false {
            mapview.removeAnnotation(spotArray.last!)
        }
        
        setGetLocationButton()
        createPreviousAnnotationFromRealm()
        setInitalMapView(initialLocation)
    }
    
    
    @IBAction func mainButtonAction(sender: UIButton) {
        if gettingLocation {
            clearAction()
        } else if location == nil {
            getLocation()
            longitudeLabel.hidden = true
        } else if location != nil {
            saveAction()
        }
    }
    
    
    
    // MARK:- ** Functions **
    func createPreviousAnnotationFromRealm() {
        let results = Array(realm.objects(Annotations))
        
        for spot in results {
            let coordinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
            let tempSpot = FoundSpot(title: spot.title, coordinate: coordinate, info: spot.info)
            previouslySavedSpots.append(tempSpot)
        }
        mapview.addAnnotations(previouslySavedSpots)
    }

    func save() {
        let spot = Annotations()
        spot.title = titleToSave
        spot.info = infoToSave
        spot.longitude = (spotArray.first?.coordinate.longitude)!
        spot.latitude = (spotArray.first?.coordinate.latitude)!
        try! realm.write({
            realm.add(spot)
        })
        
    }
    
    func saveAction() {
        showSaveAlertForTitleAndInfoInput()
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
            
            let annotation = FoundSpot(title:"", coordinate: location.coordinate, info:"")
            spotArray.append(annotation)
            mapview.addAnnotation(spotArray.last!)
        } else {
            clearButtonOutlet.hidden = true
            latitudeLabel.hidden = true
            longitudeLabel.hidden = true
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
    
}



// MARK:-  ** Button Appearence **
extension GetLocationViewController {
    func setGetLocationButton() {
        
        mainButtonOutlet.hidden = false
        mainButtonOutlet.setTitle("Get", forState: .Normal)
        mainButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mainButtonOutlet.setBackgroundImage(UIImage(named: "MainButtonGreen"), forState: .Normal)
        longitudeLabel.hidden = false
        longitudeLabel.text = "tap 'Get' to Begin"
        
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


    // MARK:-  ** Basic Map Control **
extension GetLocationViewController {
    func setInitalMapView(location: CLLocation) {
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(50, 50)
        let coordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, theSpan)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapview.setRegion(coordinateRegion, animated: true)
    }

}



    // MARK:-  ** Location Management **
extension GetLocationViewController {
    
    func stopLocationManager() {
        if gettingLocation == true {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            gettingLocation = false
            
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
            
            setGetLocationButton()
            
        }
    }
    
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            setStopButton()
            
            gettingLocation = true
        }
    }
    
    
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


// MARK:- ** Alerts **
extension GetLocationViewController {
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services for 'Spot Marker' in your Settings App", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showSaveAlertForTitleAndInfoInput() {
        let alert = UIAlertController(title: "Enter a Title and some Info about the 'Spot'", message: "Enter A Title First", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
        textField.placeholder = "Enter a Title"
        })
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler:  {void in
            let textfield = alert.textFields![0] as UITextField
            self.titleToSave = textfield.text!
            self.infoInputAlert()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { void in
            self.resignFirstResponder()
        })
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func infoInputAlert() {
        let alert = UIAlertController(title: "Enter a Title and some Info about the 'Spot'", message: "Now Enter a bit of Info", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter A brief Description"
        })
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { void in
            let textField = alert.textFields![0] as UITextField
            self.infoToSave = textField.text!
            self.setGetLocationButton()
            self.save()
            self.clearAction()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { void in
            self.resignFirstResponder()
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
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
