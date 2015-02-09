//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by BX_mbp on 14/12/4.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import UIKit
class CategoryPickerViewController:UITableViewController {
    var selectedCategoryName = ""
    let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"]
    var selectedIndexPath = NSIndexPath()
    
    //MARK: -UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        if categoryName == selectedCategoryName{
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        }else{
            cell.accessoryType = .None
        }
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath){
                newCell.accessoryType = .Checkmark
            }
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath){
                oldCell.accessoryType = .None
            }
            selectedIndexPath = indexPath
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //根据选中的index-path把categoryName放入selectedCategoryName.
        //close this active view
        if segue.identifier == "PickedCategory"{//unwind segue identifier is PickedCategory
            let cell = sender as UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell){
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }

}
