//
//  ListVC.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 18/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class ListVC: UIViewController {

    
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
     let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    //MARK:- Properties
    let cellID = "studentCell"
    var locationsList = [StudentLocatin]()
    
    
    //MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchStudentLocations()
        super.viewWillAppear(true)
    }
    
    
    //MARK:- Setup TableView
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
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
    
    
    
    //MARK:- Bar Button Items
    
    
    //logout
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        startActivityIndicator(view: self.view)
        Auth.instance.logOut { (complete, key, error) in
            
            if error != nil {
                self.alert(title: "Error perform request", message: "there was an error")
            }
            
            if complete {
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                }
            } else {
                self.alert(title: "Error logging out", message: "there was an error ")
                self.stopActivityIndicator()
            }
        }
    }
    
    //referresh
    @IBAction func referreshButtonPressed(_ sender: UIBarButtonItem) {
        fetchStudentLocations()
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
                guard let returnedStudentLocations = returnedStudentLocations else {
                    self.alert(title: "Error loading locations", message: "There was an error loading locations")
                    self.stopActivityIndicator()
                    return
                }
                self.locationsList = returnedStudentLocations
                self.stopActivityIndicator()
                self.tableView.reloadData()
            }
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
}






//MARK:- TableView Delegate & DataSource
extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let studentInfo = locationsList[indexPath.row]
        cell.textLabel?.text = "\(studentInfo.firstName ?? "") \(studentInfo.lastName ?? "")"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentInfo = locationsList[indexPath.row]
        let openURL = studentInfo.mediaURL
        
        tableView.deselectRow(at: indexPath, animated: true)
        if verifyUrl(urlString: openURL) {
            guard let url = URL(string: openURL! ) else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
}
