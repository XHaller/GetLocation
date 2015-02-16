//
//  FirstViewController.swift
//  MyLocations
//
//  Created by BX_mbp on 14/11/11.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController,
                                CLLocationManagerDelegate{
    let locationManager = CLLocationManager() //获取gps坐标的对象
    var location: CLLocation? //储存坐标的变量，值可以为空
    var updatingLocation = false
    //状态值，当值为真表示正在寻找坐标，改变Get My Location按钮和status message的显示
    var lastLocationError: NSError? //取坐标错误
    let geocoder = CLGeocoder() //解码类的对象
    var placemark: CLPlacemark? //存储地址的变量
    var performingReverseGeocoding = false //根据gps数据取地址
    var lastGeocodingError: NSError? //取地址错误
    var timer: NSTimer?
    
    var managedObjectContext: NSManagedObjectContext!
    
   
    
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var latitudeLabel:UILabel!
    @IBOutlet weak var longtitudeLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var tagBotton:UIButton!
    @IBOutlet weak var getBotton:UIButton!
    //in the storyboard, c－drag to creat a outlet
    
    @IBAction func getLocation(){
        let authStatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        //获取使用权限，还有“Always” 权限
        if authStatus == .NotDetermined{
            //如果没有确认权限，弹出权限要求
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted{
            //如果第一次没有获得权限，将弹出警告
            showLocationServicesDeniedAlert()
            return
        }
        if updatingLocation{
            //如果已经在get location，那么按这个按钮就是stop
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation"{
            //点击tagLocation，出现locationDetail新页面
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as LocationDetailsViewController
            //将navigationController最上面的viewController赋值给controller
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            //将值传递给LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            //pass the context to tag location screen
        }
        
            
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLocationServicesDeniedAlert(){
        //如果用户首次拒绝了使用权限，使用时会弹出警告，要求用户设置权限
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        //更新label的方法
        if let location = location{
            //用if let 拆包
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            //latitudeLabel显示gps数值，用到了format string技巧
            longtitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagBotton.hidden = false
            messageLabel.text = ""
            if let placemark = placemark{
                //更新addressLabel文本
                addressLabel.text = stringFromPlacemark(placemark)
            }else if performingReverseGeocoding{
                addressLabel.text = "Searching for Address..."
            }else if lastLocationError != nil{
                addressLabel.text = "Error Finding Address"
            }else {
                addressLabel.text = "No Address Found"
        }
        }else{
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            addressLabel.text = ""
            tagBotton.hidden = true
            var statusMessage:String
            if let error = lastLocationError {
                //将各种错误信息存入statusMessage变量
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.Denied.rawValue{
                        statusMessage = "Location Services Disabled"
                }else{
                    statusMessage = "Error Getting Location"
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Ddisabled"
            }else if updatingLocation{
                statusMessage = "Searching..."
            }else{
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self //指明manager对象的委托是视图控制器
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //设置精度
            locationManager.startUpdatingLocation() //把gps数据发给它的委托--视图控制器
            updatingLocation = true //开始寻找坐标
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
            //60s设置为超时
        }
    }
    func stopLocationManager(){
        //取坐标错误，停止manager运行
        if updatingLocation{
            if let timer = timer{
                //当寻找坐标很快结束或用户手动停止时，使timer不可用
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    func configureGetButton(){
        //在取值时变化get my location按钮的形态
        if updatingLocation{
            getBotton.setTitle("Stop", forState: .Normal)
        }else{
            getBotton.setTitle("Get MyLocation", forState: .Normal)
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark)->String{
        //将地址变成字符串以显示
        //line1即文本第一行
        var line1 = ""
        //如果有subThoroughfare，则加入第一行
        if placemark.subThoroughfare != nil {
            line1 += placemark.subThoroughfare
        }
        //如果line1不为空在thoroughfare之前加入空格
        if placemark.thoroughfare != nil {
            if !line1.isEmpty {
                line1 += " "
            }
            line1 += placemark.thoroughfare
        }
        //文本第二行
        var line2 = ""
        if placemark.locality != nil {
            line2 += placemark.locality
        }
        if placemark.administrativeArea != nil {
            if !line2.isEmpty {
                line2 += " "
            }
            line2 += placemark.administrativeArea
        }
        if placemark.postalCode != nil {
            if !line2.isEmpty {
                line2 += " "
            }
            line2 += placemark.postalCode
        }
        
        return line1 + "\n" + line2
    }
    
    func didTimeOut(){
        //println("***Time out")
        //处理取坐标超时情况
        if location == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }

//MARK: -CLLocationManagerDelegate
//locationManager的委托方法

func locationManager(manager:CLLocationManager!,
    didFailWithError error:NSError!){
        //println("didFailWithError \(error)")
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
}

func locationManager(manager:CLLocationManager!,
    didUpdateLocations locations:[AnyObject]!){
        let newLocation = locations.last as CLLocation
        //println("didUpdateLocations \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            //废弃过时的数据
            return
        }
        if newLocation.horizontalAccuracy < 0{
            //废弃精确度小于旧值的新值
            return
        }
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            //计算新旧两个location之间的距离
            distance = newLocation.distanceFromLocation(location)
        }
        //3
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            //新值比旧值精确，越精确horizontalAccuracy越小
            lastLocationError = nil //清空旧的错误信息
            location = newLocation //坐标存入location变量
            updateLabels()
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                //取值达到要求的精度
                //println("***We're done!")
                stopLocationManager()
                configureGetButton()
                if distance > 0 {
                    performingReverseGeocoding = false
                    //对最后一个左边进行地址解码
                }
            }
            
            if !performingReverseGeocoding{
                //println("***Going to geocode")
                
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(location, completionHandler: {placemarks, error in
                //闭包，placemarks，error相当于函数形参
                //println("*** Found placemarks:\(placemarks),error:\(error)")
                    self.lastGeocodingError = error
                    if error == nil && !placemarks.isEmpty{
                        //当没有错误和地址数组不为空时，取出地址。是一种防御式编程。
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        }else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                //10s时间内distance变化不大，则停止manager，更新label。
                //println("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
        
    }

}