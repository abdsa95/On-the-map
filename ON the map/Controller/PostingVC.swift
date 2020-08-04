//
//  PostingVC.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 20/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import UIKit

class PostingVC: UIViewController {

    
    //MARK:- Outlets
    @IBOutlet weak var textField: UITextField!
    
    //MARK:- Properties
    let identifier = "gotoFindOntheMapVC"
    
    
    //MARK:- Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }
    
    
    //MARK:- Find on the map button
    @IBAction func findOnTheMapButtonPressed(_ sender: Any) {
        if textField.text != "" && textField.text != "Enter your Location here!" {
            findOnTheMap()
        }
    }
    
    
    
    func findOnTheMap(){
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifier {
            let FindVC = segue.destination as! FindOnTheMapVC
            FindVC.locationString = textField.text!
        }
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}






//MARK:- TextField Delegate
extension PostingVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
        
    }
}

