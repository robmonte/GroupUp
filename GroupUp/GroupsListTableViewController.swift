//
//  GroupsListTableViewController.swift
//  GroupUp
//
//  Created by Robert Montefusco on 3/19/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class GroupsListTableViewController: UITableViewController {
    
    @IBOutlet var groupTable: UITableView!
    
    //private var groups = [NSManagedObject]()
    private var groups = [String]()
    public var username:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Your Groups"
        
        IJProgressView.shared.showProgressView(self.view)
        loadGroups()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if groups.count == 1 && groups[0] == "" {
            return 0
        }
        else {
            return groups.count
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsListID", for: indexPath)
        cell.backgroundColor = self.view.backgroundColor
        
        cell.textLabel?.text = groups[indexPath.row]
        
        return cell
    }
    
    func loadGroups() {
        let rootRef = FIRDatabase.database().reference()
        let groupsRef = rootRef.child("Groups")
        
        let query = groupsRef.queryOrdered(byChild: username).queryEqual(toValue: username)
        
        query.observe(.value, with: { snapshot in
            let userGroups = snapshot.value as? NSDictionary
            let retList = userGroups?.allKeys as? [String]
            print(retList ?? [""])
            
            self.groups = retList ?? [""]
            
            DispatchQueue.main.async {
                self.groupTable.reloadData()
                IJProgressView.shared.hideProgressView()
            }
        })
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationVC = segue.destination as? GroupDetailsViewController {
            let index = tableView.indexPathForSelectedRow?.row
            //let groupName:String? = groups[index!].value(forKey: "groupName") as? String
            let groupName:String = groups[index!]
            
            destinationVC.groupName = groupName
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
