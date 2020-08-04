//
//  AuthVC.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 18/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit
import SafariServices

class AuthVC: UIViewController {

    
    
    //MARK:- Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    //MARK:- Properties
    let identifier = "gotoMap"
    
    
    //MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
    }

    
    //MARK:- Alert
    func alert(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Update UI
    func uodateUI(loginButtonIsEnabled: Bool, signupButtonIsEnabled: Bool){
        loginButton.isEnabled = loginButtonIsEnabled
        signupButton.isEnabled = signupButtonIsEnabled
    }
    
    
    //MARK:- Login Button 
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        startActivityIndicator(view: self.view)
        uodateUI(loginButtonIsEnabled: false, signupButtonIsEnabled: false)
        if (email.text!.isEmpty) || (password.text!.isEmpty) {
            alert(title: "fill the required field", message: "please fill both email and password")
            stopActivityIndicator()
        } else {
            Auth.instance.login(withEmail: email.text!, AndPassword: password.text!) { (complete, key, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self.alert(title: "Error performing request", message: "There was an error performing your request")
                        self.stopActivityIndicator()
                    }
                    if !complete {
                        self.alert(title: "Error logging in ", message: "Password or email may be incorrect")
                        self.stopActivityIndicator()
                    } else {
                        (UIApplication.shared.delegate as! AppDelegate).uniqueKey = key
                        self.stopActivityIndicator()
                        self.performSegue(withIdentifier: self.identifier , sender: self)
                    }
                }
            }
        }
        
        uodateUI(loginButtonIsEnabled: true, signupButtonIsEnabled: true)
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
    
    
    
    //MARK:- Logout Button
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        let urlString = "https://auth.udacity.com/sign-up"
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    }





//MARK:- TextField Delegate
extension AuthVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
