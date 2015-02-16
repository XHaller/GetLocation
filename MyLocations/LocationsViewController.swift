//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by BX_mbp on 15/1/23.
//  Copyright (c) 2015年 BX_mbp. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        //sort on the date attribute, in ascending order.
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        //returns an array with the sorted objects
        fetchRequest.fetchBatchSize = 20
        //only fetch the objects that you can actually see
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()//导航右键编辑
        performFetch()
        // To retrieve an object that you previously saved to the data store, you create a fetch request that describes the search parameters of the object
    }

    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }

    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as LocationCell
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
        //ask the fetchedResultsController for the object at the requested index-path
        cell.configureForLocation(location)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
            location.removePhotoFile()
            managedObjectContext.deleteObject(location)
            var error: NSError?
            if !managedObjectContext.save(&error) {
            fatalCoreDataError(error) }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
                controller.locationToEdit = location
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                    return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }

    
}


extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            //NSFetchedResultsController will invoke these methods to let you know that certain objects were inserted, removed, or just updated.
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                println("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                println("*** NSFetchedResultsChangeUpdate (object)")
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as LocationCell
                let location = controller.objectAtIndexPath(indexPath!) as Location
                cell.configureForLocation(location)
            case .Move:
                println("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
            switch type {
                case .Insert:
                    println("*** NSFetchedResultsChangeInsert (section)")
                    tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                case .Delete:
                    println("*** NSFetchedResultsChangeDelete (section)")
                    tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                case .Update:
                    println("*** NSFetchedResultsChangeUpdate (section)")
                case .Move:
                    println("*** NSFetchedResultsChangeMove (section)")
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}


