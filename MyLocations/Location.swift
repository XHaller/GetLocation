//
//  MyLocations.swift
//  MyLocations
//
//  Created by BX_mbp on 14/12/9.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject, MKAnnotation {
    //Protocols let objects wear different hats.

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var photoID: NSNumber?
    
    var coordinate: CLLocationCoordinate2D {
       return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String! {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    var subtitle: String! {
        return category
    }
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(photoID != nil, "NO photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
    }
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)  //从photoPath读取图片
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID = userDefaults.integerForKey("PhotoID")
        userDefaults.setInteger(currentID + 1, forKey: "photoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            //删除照片
            let path = photoPath
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path) {
                var error: NSError?
                if !fileManager.removeItemAtPath(path, error: &error) {
                  println("error removing file: \(error!)")
                }
            }
        }
    }

}
