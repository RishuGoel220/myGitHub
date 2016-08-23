//
//  OtpController.swift
//  
//
//  Created by Rishu Goel on 22/08/16.
//
//

import UIKit

class OtpController: UIViewController {
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var username:String = ""
    var  password:String = ""
    @IBOutlet weak var otpTextField: UITextField!
    @IBAction func otpButtonPressed(sender: UIButton) {
        APIcaller().loginOTP(username, password: password,otp: otpTextField.text!){jsondata, response in
            self.activityIndicator.hidden = true
            
            if response.response?.statusCode==200 || response.response?.statusCode==201{
                ViewController().addUserToDatabase(self.username)
                self.performSegueWithIdentifier("otpLoginSegue", sender: self)
                
            }
            else if response.result.description == "SUCCESS" {
                
                    self.activityIndicator.hidden = true
                    let startIndex = response.result.debugDescription.rangeOfString("message")?.endIndex.advancedBy(4)
                    let finalIndex = response.result.debugDescription.endIndex.advancedBy(-4)
                    let rangeMessage = Range<String.Index>(start: startIndex!, end: finalIndex)
                    let alert = UIAlertView(title: "Invalid", message: "Error : \(response.result.debugDescription.substringWithRange(rangeMessage))", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                // with different status code what to do   401 wrong credentials 403 forbidden 404 -1
            }
            else{
                self.activityIndicator.hidden = true
                let alert = UIAlertView(title: "Invalid", message: "Error : \((response.result.error?.localizedDescription)! as String)", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}
