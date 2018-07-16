//
//  HouseCollectionVC.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit
class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var textLabel: UILabel!
    
}
class HouseCollectionVC: UICollectionViewController {

    @IBAction func hamburgerTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "asd", for: indexPath) as! SectionHeader
        cell.textLabel.text = "\(indexPath.section) BHK Flats Apartments near you"
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "houseCell", for: indexPath)
        return cell
    }
}
