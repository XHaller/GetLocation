//
//  MapViewController.swift
//  MyLocations
//
//  Created by BX_mbp on 15/2/8.
//  Copyright (c) 2015年 BX_mbp. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var locations = [Location]()
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext, queue: NSOperationQueue.mainQueue()) {notification in
                if self.isViewLoaded(){
                    self.updateLocations()
                }
            }
        }
    }
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        //calls regionForAnnotations() to calculate a reasonable region that fits all the Location objects and then sets that region on the map view.
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
    }
    
    func showLocationDetails(sender: UIButton) {
        performSegueWithIdentifier("EditLocation", sender: sender)
    }
    
    func updateLocations() {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        mapView.removeAnnotations(locations)
        locations = foundObjects as [Location]
        //add a pin for each location on the map.
        mapView.addAnnotations(locations)
    }
    
    func regionForAnnotations(annotations: [MKAnnotation]) ->MKCoordinateRegion {
        //It assumes that all the objects in the array conform to the MKAnnotation protocol
        var region: MKCoordinateRegion
        switch annotations.count {
            case 0:
                //There are no annotations.
                region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            case 1:
                //There is only one annotation.
                let annotation = annotations[annotations.count - 1]
                region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            default:
                //There are two or more annotations.
                var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
                var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
                for annotation in annotations {
                    topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                    topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                    bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                    bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
                
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            //using the tag property of the sender button as the index in that array.
            let button = sender as UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
}
    

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //determine whether the annotation is really a Location object.
        if annotation is Location {
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKPinAnnotationView!
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                //sets some properties.
                annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = false
                annotationView.pinColor = .Green
                //hook up the button’s “Touch Up Inside” event with a new showLocationDetails() method.
                let rightBotton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
                rightBotton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
                annotationView.rightCalloutAccessoryView = rightBotton
            } else {
                annotationView.annotation = annotation
            }
            //obtain a reference to that detail disclosure button again and set its tag to the index of the Location object in the locations array.
            let button = annotationView.rightCalloutAccessoryView as UIButton
            if let index = find(locations, annotation as Location) {
                button.tag = index
            }
            return annotationView
            
        }
        return nil
    }
}

extension MapViewController: UINavigationBarDelegate {
    //the gap between the navigation bar and the top of the screen is gone.
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
