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
//------------------------------------------------------------------------------
// DESCRIPTION: This is the Controller for the Login screen 
//------------------------------------------------------------------------------
class ViewController: UIViewController {
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let apiCaller = APIcaller()
// MARK: LABELS
// ---------------- Labels for Login Page -----------------------
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    
// MARK: action on text fields
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

// MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.otpTextField.hidden = true
        setBackgroudImage()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
//------------------- Login Function ------------------------------
    func loginAction(otpField  :String){
        
        // check if  both username and password is not given
        guard usernameTextField.text?.characters.count > 0 || passwordTextField.text?.characters.count > 0 else {
            showValidationAlertWithMessage("Username and Password cannot be left blank")
            //usernameTextField.becomeFirstResponder()
            return
        }
        // check if username is not given
        guard usernameTextField.text?.characters.count > 0 else {
            showValidationAlertWithMessage("Please Enter Username")
            //usernameTextField.becomeFirstResponder()
            return
        }
        // check if password is not given
        guard passwordTextField.text?.characters.count > 0 else {
            //passwordTextField.resignFirstResponder()
            showValidationAlertWithMessage("Please Enter Password")
            return
        }

        // if username and password is filled start loading status
        startActivityIndicator()
        
        // call api for login
        self.apiCaller.login(usernameTextField.text!, password: passwordTextField.text!, otp: otpField)
        { response in
            // on response stop loading
            self.stopActivityIndicator()

            switch response.result {
            // if response has sucess
            case let .Success(successValue) :
                let successjsonData = JSON(successValue)
                // if there is no message then its a successful login
                guard let messageString = successjsonData.dictionaryValue["message"]?.stringValue where messageString.characters.count > 0 else {
                    DatabaseHandler().addUser(self.usernameTextField.text!)
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                    return
                }
                // if there is message check if it has otp required text else show error message
                guard let _ = response.response?.allHeaderFields["X-GitHub-OTP"]?.containsString("required") else {
                    self.showErrorAlertWithMessage(messageString)
                    return
                }
                // if otp is asked set up the view for otp login
                self.viewSetupForOTP()
                
            // show alert when there is failure with error message
            case let .Failure(errorValue) :
                print(errorValue)
                self.showErrorAlertWithMessage(errorValue.localizedDescription)
            }
            
        }
    }
    
    // Make the login password field hidden and otp visible for otp login
    func viewSetupForOTP(){
        self.otpTextField.hidden = false
        self.usernameTextField.hidden = true
        self.passwordTextField.hidden = true
        self.otpTextField.resignFirstResponder()
        
    }
    
    
    // show error alerts
    func showErrorAlertWithMessage(message: String?) {
        let messageString = message ?? "Something Went Wrong"
        let alert = UtilityHandler().showAlertWithSingleButton("Invalid", message: "Error : \(messageString)")
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    // show validation alerts
    func showValidationAlertWithMessage(message: String?) {
        let alert = UtilityHandler().showAlertWithSingleButton("Invalid", message: message!)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

// MARK: Utility functions
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
    // set backgorund for login screen
    func setBackgroudImage(){
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "backgroundLogin2")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        imageViewBackground.alpha = 0.8
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
    }
}


