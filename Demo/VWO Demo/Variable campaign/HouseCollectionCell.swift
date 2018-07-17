//
//  HouseCollectionCell.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 16/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit

class HouseCollectionCell: UICollectionViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    @IBOutlet weak var houseImagefield: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        houseImagefield.layer.cornerRadius = 10
        houseImagefield.clipsToBounds = true
    }
}
