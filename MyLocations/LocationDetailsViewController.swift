//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by BX_mbp on 14/12/2.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Dispatch//low-level library for handling asynchronous tasks.

//创建dateFormatter常量并设置它的属性
private let dateFormatter: NSDateFormatter = {
    // the code that sets up the NSDateFormatter object using a closure
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var coordinate = CLLocationCoordinate2D(latitude:0, longitude:0)
    //CLLocationCoordinate2D是一个struct
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"//临时储存选中的category
    var date = NSDate()//存储现在时刻的时间
    var locationToEdit: Location? {
        //the code in this block is performed whenever you put a new value into the variable.
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    //outlet properties
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    //two action methods that both dismiss the screen
    
    @IBAction func done(){
        //Creates a HudView object and adds it to the navigation controller's view
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        var location: Location
        if let temp = locationToEdit {
            //更新location
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as Location
        }
        //ask the NSEntityDescription class to insert a new object for your entity into the managed object context.
        location.locationDescription = descriptionText
        //set Location object's properties to whatever the user entered in the screen.
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        //save the context
        var error: NSError?
        if !managedObjectContext.save(&error){
            fatalCoreDataError(error)
            return
        }
        //using a free function(in the functions.swift)to delay 0.6s
        afterDelay(0.6, {
            self.dismissViewControllerAnimated(true, completion: nil)
            }
            //tell the view controller to dismiss itself.
        )
    }
    
    @IBAction func cancel(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //给每个标签赋值
        if let location = locationToEdit {
            title = "Edit Location"
        }
        descriptionTextView.text = ""
        categoryLabel.text = ""
        latitudeLabel.text = String(format:"%.8f",coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude )
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        }else{
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(date)
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        //用UITapGestureRecognizer实现点击textView意外其他地方隐藏键盘
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func hideKeyboard(gestureReconizer:UIGestureRecognizer){
        let point = gestureReconizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0{
            //点到section＝0不隐藏键盘
            return
        }
        descriptionTextView.resignFirstResponder()
        
    }
    
    func stringFromPlacemark(placemark: CLPlacemark)->String {
        //返回地址字符串的函数
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare)," +
        "\(placemark.locality)," +
        "\(placemark.administrativeArea) \(placemark.postalCode)," +
        "\(placemark.country)"
    }
    
    func formatDate(date: NSDate)->String{
        //返回日期字符串的函数
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //对table view中的cell设置高度
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        }else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()//自适应
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        }else{
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) ->NSIndexPath?{
        if indexPath.section == 0 || indexPath.section == 1 {
            //点击前两个sections中的cells返回indexPath
            return indexPath
        }else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            //点击文本栏即响应
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //prepareForSegue(sender) method，由detail页面跳转到categoryPicker页面
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue){
        //to make a unwind segue
        let controller = segue.sourceViewController as CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    override func viewWillLayoutSubviews() {
        //文本栏textView的Autosizing代码
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
}

extension LocationDetailsViewController: UITextViewDelegate {
    //建立textView的delegate
    func textView(textView: UITextView, shouldChangeTextInRange
        range: NSRange, replacementText text: String) -> Bool {
            //将text转为字符串
            descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
}


