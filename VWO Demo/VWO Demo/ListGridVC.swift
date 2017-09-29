//
//  ListGridVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO

struct Phone {
    let name: String
    let manufacturer: String
    let price: Int
    let image: UIImage
}

enum ListType: String {
    case list, grid
    func cellSize(for collectionView: UICollectionView) -> CGSize {
        switch self {
        case .list: return CGSize(width: collectionView.bounds.width / 1, height: 110)
        case .grid: return CGSize(width: collectionView.bounds.width / 2, height: 230)
        }
    }
    var lineSpacing: CGFloat {
        switch self {
        case .list: return 0
        case .grid: return 25
        }
    }
    
    var navDecription: String {
        switch self {
        case .list: return "List View"
        case .grid: return "Grid View"
        }
    }
}

class ListGridVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var listType = ListType.list
    var detailVC: DetailsVC! = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scroll") as! DetailsVC

    let phoneList = [
        Phone(name: "iPhone 6 (16GB, Black)", manufacturer: "Apple", price: 399, image: #imageLiteral(resourceName: "iPhone")),
        Phone(name: "Samsung Galaxy S8 (64GB, Black)", manufacturer: "Samsung", price: 799, image: #imageLiteral(resourceName: "S8")),
        Phone(name: "Google Pixel (32GB, Very Silver)", manufacturer: "Google", price: 699, image: #imageLiteral(resourceName: "Pixel")),
        Phone(name: "ZTE Max XL (16GB)", manufacturer: "ZTE", price: 129, image: #imageLiteral(resourceName: "ZTE Max")),
    ]

    class func makeViewFor(type: ListType) -> ListGridVC {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listGrid") as! ListGridVC
        vc.listType = type
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(detailVC.view)
        detailVC.view.isHidden = true
        self.view.equalConstrains(subView: detailVC.view)
    }
}

//MARK: - UICollectionViewDataSource
extension ListGridVC :  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phoneList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listType.rawValue, for: indexPath) as! GridCellView
        let currentPhone = phoneList[indexPath.row]
        cell.phoneImageField.image = currentPhone.image
        cell.titleLabelField.text = currentPhone.name
        cell.subTitleLabelField.text = "by \(currentPhone.manufacturer)"
        cell.priceLabelField.text = "$\(currentPhone.price)"
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
extension ListGridVC : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return listType.cellSize(for: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return listType.lineSpacing;
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        VWO.markConversionFor(goal: "productView")
        detailVC.setViewFor(phone: phoneList[indexPath.row])
        detailVC.view.isHidden = false
    }
}
