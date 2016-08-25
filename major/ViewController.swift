//
//  ViewController.swift
//  major
//
//  Created by Rishu Goel on 13/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import SwiftyJSON
import KeychainAccess
import CoreData

class ViewController: UIViewController {
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let apiCaller = APIcaller()
    
// ---------------- Labels for Login Page -----------------------
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    
//---------------- Actions For Textfields -----------------------
    @IBAction func userNameReturnPressed(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordReturnPressed(sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        loginAction("")
        
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        loginAction(otpTextField.text!)
    }

//------------------- Login Function ------------------------------
    func loginAction(otpField  :String){
        
        guard usernameTextField.text?.characters.count > 0 || passwordTextField.text?.characters.count > 0 else {
            showValidationAlertWithMessage("Username and Password cannot be left blank")
            //usernameTextField.becomeFirstResponder()
            return
        }
        
        guard usernameTextField.text?.characters.count > 0 else {
            showValidationAlertWithMessage("Please Enter Username")
            //usernameTextField.becomeFirstResponder()
            return
        }
        
        guard passwordTextField.text?.characters.count > 0 else {
            //passwordTextField.resignFirstResponder()
            showValidationAlertWithMessage("Please Enter Password")
            return
        }

        // if username and password is filled
        startActivityIndicator()
        
        self.apiCaller.login(usernameTextField.text!, password: passwordTextField.text!, otp: otpField)
        { jsondata, response in
            
            self.stopActivityIndicator()

            switch response.result {
            case let .Success(successValue) :
                let successjsonData = JSON(successValue)
                guard let messageString = successjsonData.dictionaryValue["message"]?.stringValue where messageString.characters.count > 0 else {
                    print(successjsonData)
                    DatabaseHandler().addUser(self.usernameTextField.text!)
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                    return
                }

                guard let _ = response.response?.allHeaderFields["X-GitHub-OTP"]?.containsString("required") else {
                    self.showErrorAlertWithMessage(messageString)
                    return
                }

                self.otpTextField.hidden = false
                self.usernameTextField.hidden = true
                self.passwordTextField.hidden = true
                self.otpTextField.resignFirstResponder()
                
            case let .Failure(errorValue) :
                print(errorValue)
                self.showErrorAlertWithMessage(errorValue.localizedDescription)
            }
            
        }
    }
    
    func showErrorAlertWithMessage(message: String?) {
        let messageString = message ?? "Something Went Wrong"
        showAlert("Invalid", "Error : \(messageString)")
    }
    
    func showValidationAlertWithMessage(message: String?) {
        showAlert("Invalid", message)
    }
    
    func showAlert(title: String? = nil, _ message: String? = nil) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.otpTextField.hidden = true
        setBackgroudImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "loginSegue" {
            let destination = segue.destinationViewController as? UITabBarController
        }
        
    }
    
    func startActivityIndicator(){
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidden = false
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
    }

    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        
    }
    
    func setBackgroudImage(){
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "backgroundLogin2.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        imageViewBackground.alpha = 0.8
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
    }
}


