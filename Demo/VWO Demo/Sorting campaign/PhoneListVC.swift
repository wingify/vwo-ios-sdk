//
//  File.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit
import VWO

class PhoneListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var sortPhoneAlphabetically: (Phone, Phone) -> Bool {
        return { a, b in
            return a.name.lowercased() < b.name.lowercased()
        }
    }

    private var sortPhoneByPrice: (Phone, Phone) -> Bool {
        return { a, b in
            return a.price < b.price
        }
    }

    lazy var phoneList = [
        Phone(name: "iPhone 6", manufacturer: "Apple", price: 399, image: #imageLiteral(resourceName: "iPhone")),
        Phone(name: "Samsung Galaxy S8", manufacturer: "Samsung", price: 799, image: #imageLiteral(resourceName: "S8")),
        Phone(name: "Google Pixel", manufacturer: "Google", price: 699, image: #imageLiteral(resourceName: "Pixel")),
        Phone(name: "ZTE Max XL", manufacturer: "ZTE", price: 129, image: #imageLiteral(resourceName: "ZTE Max")),
        Phone(name: "Galaxy J250", manufacturer: "Samsung", price: 400, image: #imageLiteral(resourceName: "Galaxy J250")),
        Phone(name: "Honor 7X", manufacturer: "Honor", price: 299, image: #imageLiteral(resourceName: "Honor 7X")),
        Phone(name: "Mi Mix 2", manufacturer: "Mi", price: 350, image: #imageLiteral(resourceName: "Mi Mix 2")),
        Phone(name: "Redmi Y2", manufacturer: "Redmi", price: 500, image: #imageLiteral(resourceName: "Redmi Y2")),
        Phone(name: "One plus 6", manufacturer: "One plus", price: 550, image: #imageLiteral(resourceName: "One plus 6"))
        ]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(segue.destination) \(segue.source)")
        let destination = segue.destination as! PhoneDetailVC
        let t = tableView.indexPathForSelectedRow!.row
        VWO.trackConversion("productView")
        destination.phone = phoneList[t]
    }

    @IBAction func hamburgerTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }


    @IBAction func reloadTapped(_ sender: Any) {
        let variation = VWO.variationNameFor(testKey: "sorting")
        switch variation {
        case "Control":
            phoneList.sort(by: sortPhoneAlphabetically)
        case "Variation-1":
            phoneList.sort(by: sortPhoneByPrice)
        default:
            print("Default")
            break
        }
        tableView.reloadData()
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
