//
//  FeedTableViewController.swift
//  PictyFeed
//
//  Created by Timothy Acorda on 9/16/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    var messages = [String]()
    var usernames = [String]()
    var users = [String: String]()
    var Images = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var userQuery = PFUser.query()
        userQuery?.findObjectsInBackgroundWithBlock({ (objects, err) -> Void in
            if let users = objects {
                for user in users {
                    if let object = user as? PFUser {
                        self.users[object.objectId!] = object.username!
                    }
                }
            }
        
        
        var getFollowersQuery = PFQuery(className: "Followers")
        getFollowersQuery.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
        getFollowersQuery.findObjectsInBackgroundWithBlock { (objects, err) -> Void in
            if let objectsArr = objects {
                for row in objectsArr {
                    var followedUser = row["following"] as! String
                    var query = PFQuery(className: "ImagePost")
                    query.whereKey("userId", equalTo: followedUser)
                    query.findObjectsInBackgroundWithBlock({ (objects, err) -> Void in
                        if let images = objects {
                            for image in images {
                                self.messages.append(image["message"] as! String)
                                self.Images.append(image["imageFile"] as! PFFile)
                                self.usernames.append(self.users[image["userId"] as! String]!)
                                self.tableView.reloadData()
                                
                            }
                        }
                    })
                }
            }
        }
     })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.Images.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedCell
        Images[indexPath.row].getDataInBackgroundWithBlock { (data, err) -> Void in
            if let image = UIImage(data: data!) {
                cell.postedImage.image = image
            }
        }
        cell.username.text = self.usernames[indexPath.row]
        cell.titleMessage.text = self.messages[indexPath.row]
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
