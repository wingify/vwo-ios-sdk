//
//  File.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018-2022 Wingify. All rights reserved.
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
        
//      let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["groupId":"8"])
//        let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["test_key":"ME123"])
//        let TestKey =  VWO.getCampaign("9c3832ad-15f9-420a-93cd-a7f2cde0f7bc", args: ["test_key":"ME123","groupId":"8"])

        destination.phone = phoneList[t]
    }

    @IBAction func hamburgerTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }


    @IBAction func reloadTapped(_ sender: Any) {

        let variation = VWO.variationNameFor(testKey: "harshcamp1")
        switch variation {
        case "Sort-Alphabetically":
            phoneList.sort(by: sortPhoneAlphabetically)
        case "Sort-By-Price":
            phoneList.sort(by: sortPhoneByPrice)
        default:
            print("Default")
            break
        }
        tableView.reloadData()
//        VWO.trackConversion("harshrevenue", value:69.0)
        VWO.trackConversion("harshgoal1")
        
        let myDictionary: [String: Any] = [
            "harsh": "Raghav",
            "key2": 42,
            "key3": 23.9,
            "key4": true
//                    "key5": Date()
        ]
        let mutableDictionary = NSMutableDictionary(dictionary: myDictionary)
//                let dict = VWO.createVWOCustomDimensionDictionary(<#Any?#>)
//                VWOCustomDimensionDictionary.init
        VWO.pushCustomDimension(customDimensionDictionary: mutableDictionary)
        
//        VWO.pushCustomDimension(customDimensionKey: "harsh", customDimensionValue: "Raghav")
        
//      let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["groupId":"36"])
//        let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["test_key":"camp5Harsh", "groupId":"36"])
//        let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["test_key":"camp5Harsh"])
//        print("Harsh TestKey @%",TestKey)
//        let TestKey =  VWO.getCampaign("e57e8bd1-fb5f-478d-80d2-5127eb5d79f7", args: ["test_key":"ME123"])
//        VWO.getCampaign("HarshUserID", args: ["test_key":"ME123","groupId":"8"])
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
