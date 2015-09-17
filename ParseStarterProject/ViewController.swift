//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    var activityIndicator:  UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func displayAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func activityViewOn() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    @IBAction func signUp(sender: AnyObject) {
    
        if self.username.text == "" || self.password.text == "" {
            displayAlert("Please complete Form", message: "Enter a username and password")
        } else {
            activityViewOn()
            var user = PFUser()
            var errorMessage = "Please try again later"
            user.username = self.username.text
            user.password = self.password.text
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if error == nil {
                    self.performSegueWithIdentifier("login", sender: self)
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                       errorMessage = errorString
                        self.displayAlert("Failed SignUp", message: errorMessage)
                    }
                }
            })
        }
    }
    
    @IBAction func logIn(sender: AnyObject) {
        if self.username.text == "" || self.password.text == "" {
            displayAlert("Please complete Form", message: "Enter a username and password")
        } else {
            activityViewOn()
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!) { (user, error) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if user != nil {
                    self.performSegueWithIdentifier("login", sender: self)
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        self.displayAlert("Failed Login", message:errorString)
                    }
                }
            }
        }
    }
}
