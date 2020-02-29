//
//  UIKitExtensions.swift
//  CollectionViewDialLayoutDemo
//
//  Created by leechanggwi on 29/02/2020.
//  Copyright © 2020 Lcg5450. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func applyRound(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    func applyRound(bezierPathRadius: CGFloat, corners: UIRectCorner) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = UIBezierPath(roundedRect: self.bounds,
                                      byRoundingCorners: .allCorners,
                                      cornerRadii: CGSize(width: bezierPathRadius, height: bezierPathRadius)).cgPath
        self.layer.mask = maskLayer
    }

    func applyFullRound() {
        self.applyRound(self.frame.height / 2.0)
    }

    func applyBorder(_ width: CGFloat = 1.0, borderColor: UIColor = UIColor.lightGray) {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
}
