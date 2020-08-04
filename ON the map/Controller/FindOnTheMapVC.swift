//
//  FindOnTheMapVC.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 20/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class FindOnTheMapVC: UIViewController {

    
    
    
    //MARK:- Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    
    //MARK:- Properties
    var locationString: String!
    var longitude: Double?
    var latitude: Double?
    var key = (UIApplication.shared.delegate as! AppDelegate).uniqueKey
    
    
    
    
    
    //MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        mapView.delegate = self
        findOnTheMap()
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
    
    
    
    
    //MARK:- Find Location on the map 
    func findOnTheMap(){
        
        self.startActivityIndicator(view: self.view)
        
        
        if locationString != nil {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = locationString
            
            let activeSearch = MKLocalSearch(request: searchRequest)
            activeSearch.start { (response, error) in
                if response == nil {
                    self.alert(title: "Error performing request", message: "there was an error")
                    self.stopActivityIndicator()
                    print(error!)
                } else {
                    
                    self.stopActivityIndicator()
                    self.latitude = response?.boundingRegion.center.latitude
                    self.longitude = response?.boundingRegion.center.longitude
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = self.locationString
                    annotation.coordinate = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
                    self.mapView.addAnnotation(annotation)
                    
                    
                    //Zoom in
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
                    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    
    
    
    
    
    //MARK:- Set Media URL
    func setMediaURL(){
        
        if verifyUrl(urlString: textField.text!) {
            guard let _ = URL(string: textField.text! ) else {return}
        } else {
            alert(title: "Invalid input URL", message: "Write a valid URL")
        }
    }
    
    
    //check for url validation
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    
    
    
    
    //MARK:- Submit Button
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        setMediaURL()
        DataServices.instance.postLocation(locationString, textField.text, key, latitude ?? 0, longitude ?? 0) { (studentLocation, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self.alert(title: "Error performing request", message: "there was an error")
                    return
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    
    //MARK:- Alert
    func alert(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
    







//MARK:- TextField Delegate
extension FindOnTheMapVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
        
    }
}



extension FindOnTheMapVC: MKMapViewDelegate {}
