//
//  File.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit

struct Phone {
    let name: String
    let manufacturer: String
    let price: Int
    let image: UIImage
}

class PhoneListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let phoneList = [
        Phone(name: "iPhone 6 (16GB, Black)", manufacturer: "Apple", price: 399, image: #imageLiteral(resourceName: "iPhone")),
        Phone(name: "Samsung Galaxy S8 (64GB, Black)", manufacturer: "Samsung", price: 799, image: #imageLiteral(resourceName: "S8")),
        Phone(name: "Google Pixel (32GB, Very Silver)", manufacturer: "Google", price: 699, image: #imageLiteral(resourceName: "Pixel")),
        Phone(name: "ZTE Max XL (16GB)", manufacturer: "ZTE", price: 129, image: #imageLiteral(resourceName: "ZTE Max")),
        ]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(segue.destination) \(segue.source)")
        let destination = segue.destination as! PhoneDetailVC
        let t = tableView.indexPathForSelectedRow!.row
        destination.phone = phoneList[t]
    }

    @IBAction func hamburgerTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }
}

extension PhoneListVC: UITabBarDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell") as! PhoneCellView
        let currentPhone = phoneList[indexPath.row]
        cell.phoneImageField.image = currentPhone.image
        cell.titleLabelField.text = currentPhone.name
        cell.subTitleLabelField.text = "by \(currentPhone.manufacturer)"
        cell.priceLabelField.text = "$\(currentPhone.price)"

        return cell
    }
}
