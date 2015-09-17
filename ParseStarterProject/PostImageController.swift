//
//  PostImageController.swift
//  PictyFeed
//
//  Created by Timothy Acorda on 9/15/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet var imagePost: UIImageView!
    
    @IBOutlet var photoTitle: UITextField!
    
    var activityIndicator = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseImage(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
       
        self.imagePost.image = image
         self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func postImage(sender: AnyObject) {
        if self.imagePost.image != nil {
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            let post = PFObject(className: "ImagePost")
            post["message"] = self.photoTitle.text
            post["userId"] = PFUser.currentUser()?.objectId!
            let imageData = UIImagePNGRepresentation(self.imagePost.image!)
            let imageFile = PFFile(name: "image.png", data: imageData!)
            post ["imageFile"] = imageFile
            post.saveInBackgroundWithBlock { (success, err) -> Void in
                self.activityIndicator.stopAnimating()
                if err == nil {
                    self.imagePost.image = nil
                    self.photoTitle.text = ""
                    self.displayAlert("Image Posted", message: "Evereyone's gunna love it! :)")
                } else {
                    self.displayAlert("Could not post image", message: "Please try again")
                }
                
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
