//
//  MapVC.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 18/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit
import MapKit



class MapVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var mapView: MKMapView!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //MARK:- Properties
    let reuseIdentifier = "pin"
    
    //MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchStudentLocations()
        super.viewWillAppear(true)
        
    }
    
    //MARK:- Alert
    func alert(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- ActivityIndicator
    func startActivityIndicator(view:UIView){
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator(){
        activityIndicator.stopAnimating()
    }
    
    //MARK:- Fetch Data
    func fetchStudentLocations(){
        DataServices.instance.getStudentLocations { (returnedStudentLocations, error) in
            DispatchQueue.main.async {
                self.startActivityIndicator(view: self.view)
                if error != nil {
                    self.alert(title: "Error performing requst", message: "There was an error performing your request")
                    self.stopActivityIndicator()
                    return
                }
                var annotations = [MKPointAnnotation]()
                
                guard let returnedStudentLocations = returnedStudentLocations else {
                    self.alert(title: "Error loading locations", message: "There was an error loading locations")
                    self.stopActivityIndicator()
                    return
                }
                
                for locations in returnedStudentLocations {
                    let latitude = CLLocationDegrees(locations.latitude ?? 0)
                    let longitude = CLLocationDegrees(locations.longitude ?? 0)
                    
                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let mediaURL = locations.mediaURL ?? ""
                    let firstName = locations.firstName ?? ""
                    let lastName = locations.lastName ?? ""
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    annotation.title = "\(firstName) \(lastName)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append(annotation)
                }
                self.mapView.addAnnotations(annotations)
                self.stopActivityIndicator()
            }
        }
    }
    
    
    
    //MARK:- Bar Button Items
    
    
    //Logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        Auth.instance.logOut { (complete, key, error) in
            
            if error != nil {
                self.alert(title: "Error perform request", message: "there was an error")
            }
            
            if complete {
                DispatchQueue.main.async {
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                }
            } else {
                self.alert(title: "Error logging out", message: "there was an error ")
            }
        }
    }
    
    
    
    //Refrresh
    @IBAction func referreshButtonPressed(_ sender: UIBarButtonItem) {
        fetchStudentLocations()
    }
}







extension MapVC: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
        
    }
}
