//
//  SpotHistoryTableViewController.swift
//  Spot Marker
//
//  Created by Sonny on 2016-06-27.
//  Copyright © 2016 Sonny. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit

class SpotHistoryTableViewController: UITableViewController {
    
    //MARK:- ** Constants and Variables **
    
    let realm = try! Realm()
    var annotations: Results<Annotation>!
    var spotHolderArray: Array<MKAnnotation> = []
    var subscription: NotificationToken?

    //MARK:- ** LifeCycle **
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print("\nInitial Saved Spots:\n\(annotations)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotations = realm.objects(Annotation)
        subscription = notificationSubscription(annotations)

    }
    
    //MARK:- ** Functions **
    
    func notificationSubscription(tasks: Results<Annotation>) -> NotificationToken {
        return tasks.addNotificationBlock { [weak self] (changes: RealmCollectionChange<Results<Annotation>>) in
            self?.updateUI(changes)
        }
    }

    func updateUI(changes: RealmCollectionChange<Results<Annotation>>) {
        switch changes {
        case .Initial(_):
            tableView.reloadData()
        case .Update(_, deletions: let deletions, insertions: let insertions, modifications: _):
            
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths(insertions.map {NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
            tableView.deleteRowsAtIndexPaths(deletions.map {NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
            tableView.endUpdates()
            
            break
        case .Error(let error):
            print(error)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PreviousSpotTableViewCell
        
        let spot = annotations[indexPath.row]
        
        cell.titleLabel.text = spot.title
        cell.latLabel.text = "Latitude: \(String(spot.latitude))"
        cell.longLabel.text = "Longitude: \(String(spot.longitude))"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            try! annotations.realm!.write {
                let annotationToDelete = self.annotations[indexPath.row]
                self.annotations.realm!.delete(annotationToDelete)
            }
            print("\n\(annotations)")
        }
    }
   

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
