//
//  HouseCollectionCell.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018-2022 Wingify. All rights reserved.
//

import UIKit

class HouseCollectionCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var houseImagefield: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

//        self.contentView.layer.cornerRadius = 12.0
//        self.contentView.layer.borderWidth = 1.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
//        self.contentView.layer.masksToBounds = true

//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        self.layer.shadowRadius = 2.0
//        self.layer.shadowOpacity = 0.5
//        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

//        self.layer.cornerRadius = 10
//        self.clipsToBounds = true
//        self.layer.masksToBounds = true
        houseImagefield.layer.cornerRadius = 10
        houseImagefield.clipsToBounds = true
    }
}
