//
//  ProductCollectionViewCell.swift
//  Demo
//
//  Created by Carlos Molina on 06/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell
{

    @IBOutlet weak var imgVwProduct: UIImageView!
    @IBOutlet weak var lbfName: UILabel!
    @IBOutlet weak var lbfPrice: UILabel!
    var product:Product?
    {
        didSet {
            loadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadData()
        
    }
    
    func loadData()
    {
        if product != nil
        {
            self.imgVwProduct.sd_setImage(with: URL(string: product?.image ?? ""), completed: nil)
            self.lbfName.text = product?.name
            self.lbfPrice.text = String(format: "$%.02f", product?.price ?? 0)
        }
    }
    
}
