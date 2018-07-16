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
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Here")
        return 5
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("King \(kind)")
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "asd", for: indexPath) as! SectionHeader
        cell.textLabel.text = "\(indexPath.section) BHK Flats Apartments near you"
        return cell
//        let label =  UILabel(frame: .zero)
//        label.text = "ASD   FSDFSADF"
//        return label
//        if kind == UICollectionElementKindSectionHeader {
//        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "houseCell", for: indexPath)
        return cell
    }
}
