//
//  UserListController.swift
//  ParseStarterProject
//
//  Created by Timothy Acorda on 9/13/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
class UserListController: UITableViewController {

    var usernames = [String: String]()
    var followers = [String: Bool]()
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing :)")
        refresher.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        refreshData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        var query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, err) -> Void in
            if let users = objects {
                self.usernames.removeAll(keepCapacity: true)
                for object in users {
                    if let user = object as? PFUser {
                        if user.objectId! != PFUser.currentUser()?.objectId {
                            self.usernames[user.objectId!] = user.username!
                            self.followers[user.username!] = false
                            let query = PFQuery(className: "Followers")
                            
                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, err) -> Void in
                                if let array = objects as? [PFObject] {
                                    if array.count > 0 {
                                        let value = self.usernames[array[0].objectForKey("following") as! String]
                                        self.followers[value!] = true
                                    }
                                }
                                if self.usernames.count == self.followers.count {
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()
                                }
                            })
                        }
                    }
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let usernames = [String](self.usernames.values)
        cell.textLabel!.text = usernames[indexPath.row]
        if followers[usernames[indexPath.row]] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let follow = PFObject(className: "Followers")
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        var userIds = [String](self.usernames.keys)
        if followers[cell.textLabel!.text!] == false {
            followers[cell.textLabel!.text!] = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            follow["follower"] = PFUser.currentUser()?.objectId
            follow["following"] = userIds[indexPath.row]
            follow.saveInBackground()
        } else {
            followers[(cell.textLabel?.text)!] = false
            cell.accessoryType = UITableViewCellAccessoryType.None
            let query = PFQuery(className: "Followers")
            
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userIds[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, err) -> Void in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        }
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
