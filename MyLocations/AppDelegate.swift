//
//  AppDelegate.swift
//  MyLocations
//
//  Created by BX_mbp on 14/11/11.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import UIKit
import CoreData
let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error: NSError?) {
    // 处理coreData错误的全局函数
    if let error = error {
        println("*** Fatal error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        //load the data model and connect it to an SQLite data store
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd"){
            //Create an NSManagedObjectModel from that URL.
            if let model = NSManagedObjectModel(contentsOfURL: modelURL){
                //Create an NSPersistentStoreCoordinator object.
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                //create an NSURL object pointing at the DataStore.sqlite file.
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                //Add the SQLite database to the store coordinator.
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType,configuration: nil, URL:storeURL,options:nil, error: &error){
                        //create the NSManagedObjectContext object
                        let context = NSManagedObjectContext()
                        context.persistentStoreCoordinator = coordinator
                        return context
                    //print error
                }else{
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            }else{
                    println("Error initializing model from: \(modelURL)")
                }
            }else{println("Could not find data model in app bundle")
        }
            abort()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        customizeAppearance()
        let tabBarController = window!.rootViewController as UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            //get a reference to the currentlocationViewController
            let currentLocationViewController = tabBarViewControllers[0] as CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            let navigationController = tabBarViewControllers[1] as UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            let forceTheViewToLoad = locationsViewController.view
            let mapViewController = tabBarViewControllers[2] as MapViewController
            mapViewController.managedObjectContext = managedObjectContext
        }
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func listenForFatalCoreDataNotifications() {
        //Tell NSNotificationCenter that you want to be notified whenever a MyManagedObjectContextSaveDidFailNotification is posted.
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            //Create a UIAlertController to show the error message.
            let alert = UIAlertController(title: "Internal Error",
                message: "There was a fatal error in the app and it cannot continue.\n\n"
                    + "Press OK to terminate the app. Sorry for the inconvenience.",
                preferredStyle: .Alert)
            //Add an action for the alert’s OK button.
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            
            alert.addAction(action)
            //present the alert
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }
}























