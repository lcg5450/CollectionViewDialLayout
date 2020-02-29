//
//  DialMenuCollectionViewCell.swift
//  CollectionViewDialLayoutDemo
//
//  Created by leechanggwi on 29/02/2020.
//  Copyright © 2020 Lcg5450. All rights reserved.
//

import UIKit

class DialMenuCollectionViewCell: UICollectionViewCell {
    
    var bgColor: UIColor = .clear {
        didSet {
            backgroundColor = bgColor
        }
    }
    
    var title: String? = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var textColor: UIColor = .white {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    @IBOutlet weak var titleLabel:UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        titleLabel.text = ""
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backgroundColor = .clear
        titleLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let degrees = 90.0; //the value in degrees
        self.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi/180));
        
        applyFullRound()
    }
}
