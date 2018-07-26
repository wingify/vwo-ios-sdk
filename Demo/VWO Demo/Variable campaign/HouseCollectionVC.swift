//
//  HouseCollectionVC.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit
import SCLAlertView
import VWO

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var textLabel: UILabel!
}

struct House {
    typealias BHK = Int
    enum Type_: String { case residential = "Residential", commercial = "Commercial"}
    let name: String
    let price: Int
    let bhk: BHK
    let type: Type_
    let image: UIImage
}

class HouseCollectionVC: UICollectionViewController {
    let houseList: [Int: [House]] = [
        1 : [
            House(name: "Sai Enclave", price: 15_00, bhk: 1, type: .residential, image: #imageLiteral(resourceName: "h1")),
            House(name: "Zero One", price: 7_00_, bhk: 1, type: .commercial, image: #imageLiteral(resourceName: "h2")),
            House(name: "Siddhartha Enclave", price: 30_0, bhk: 1, type: .residential, image: #imageLiteral(resourceName: "h3")),
            House(name: "Waterfront", price: 2_00, bhk: 1, type: .residential, image: #imageLiteral(resourceName: "h4"))
        ],
        2: [
            House(name: "Panchsheel", price: 34_0, bhk: 2, type: .residential, image: #imageLiteral(resourceName: "h5")),
            House(name: "Marvel", price: 1_00, bhk: 2, type: .residential, image: #imageLiteral(resourceName: "h6")),
            House(name: "Aurum", price: 50_0, bhk: 2, type: .residential, image: #imageLiteral(resourceName: "h7")),
            House(name: "Blue Bells", price: 70_00, bhk: 2, type: .commercial, image: #imageLiteral(resourceName: "h8"))
        ],
        3: [
            House(name: "Trump Towers", price: 5_000, bhk: 3, type: .residential, image: #imageLiteral(resourceName: "h9")),
            House(name: "ABIL", price: 7_000, bhk: 3, type: .commercial, image: #imageLiteral(resourceName: "h10")),
            House(name: "Radhe Shaam", price: 4500, bhk: 3, type: .residential, image: #imageLiteral(resourceName: "h11")),
            House(name: "DSK", price: 3400, bhk: 3, type: .residential, image: #imageLiteral(resourceName: "h12")),
        ]
    ]

    @IBAction func hamburgerTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return houseList.count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false,
            hideWhenBackgroundViewIsTapped : true
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Upgrade with $6") {
            print("Goal mark upgrade purchased")
            VWO.trackConversion("upgrade-clicked")
        }

        let heading = VWO.stringFor(key: "heading", defaultValue: "Use our House Agent!")!
        let content = VWO.stringFor(key: "content", defaultValue: "You can use our in-house agents who can help you find a suitable house.")!
        alertView.showInfo(heading, subTitle: content, closeButtonTitle: "Cancel")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return houseList[section + 1]!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let house = houseList[indexPath.section + 1]![indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "houseCell", for: indexPath) as! HouseCollectionCell
        cell.nameLabel.text = house.name
        cell.priceLabel.text = "$ \(house.price)"
        cell.typeLabel.text = house.type.rawValue
        cell.houseImagefield.image = house.image
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //////////////////////// HEADER ///////////////////////////////////////
        let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "asd", for: indexPath) as! SectionHeader
        headerCell.textLabel.text = "\(indexPath.section + 1) BHK Flats Apartments near you"

        return headerCell
    }
}

extension HouseCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let a = collectionView.bounds.width / 2
        return CGSize(width: a, height: a)
    }
}
