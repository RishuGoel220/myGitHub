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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func userNameReturnPressed(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordReturnPressed(sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        loginAction()
        
    }
    @IBAction func loginButtonPressed(sender: UIButton) {
        loginAction()
    }

    func loginAction(){
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        
        if usernameTextField.text != "" && passwordTextField.text != "" {
            
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidden = false
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            
            self.apiCaller.login(usernameTextField.text!, password: passwordTextField.text!){jsondata, response in
                self.activityIndicator.hidden = true
                if response.response?.statusCode==200 || response.response?.statusCode==201{
                    self.addUserToDatabase(self.usernameTextField.text!)
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                    
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
        else if usernameTextField.text != "" {
            let alert = UIAlertView(title: "Invalid", message: "Please Enter Password", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else if passwordTextField.text != "" {
            let alert = UIAlertView(title: "Invalid", message: "Please Enter Username", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        else{
            let alert = UIAlertView(title: "Invalid", message: "Cant leave username and password blank", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    
    
    
    
    
    func addUserToDatabase(username : String){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        
        
        do {
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0{
                let managedObject = fetchResults[0]
                managedObject.setValue("yes", forKey: "current")
                try managedContext.save()
                return
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        
        
        
        
        
        
        //2
        let entity =  NSEntityDescription.entityForName("Users",
                                                        inManagedObjectContext:managedContext)
        
        let user = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext: managedContext)
        
        //3
        user.setValue(username, forKey: "username")
        user.setValue("yes", forKey: "current")
        
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        

    
    }







    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if apiCaller.hasAuthToken() == true{
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("repositoryView") as! UINavigationController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else{
            print("No auth token")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        printUsers()
        // set image background
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "LoginImage.jpg")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        self.view.addSubview(imageViewBackground)
        self.view.sendSubviewToBack(imageViewBackground)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func printUsers(){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        
        let fetchRequest = NSFetchRequest(entityName: "Users")
        
        
        do {
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0{
                print(fetchResults)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "loginSegue" {
            let destination = segue.destinationViewController as? UINavigationController
        }
        
    }
}

