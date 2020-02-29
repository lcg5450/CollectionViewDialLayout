//
//  DialMenuCollectionViewLayout.swift
//  CollectionViewDialLayoutDemo
//
//  Created by leechanggwi on 29/02/2020.
//  Copyright © 2020 Lcg5450. All rights reserved.
//

import UIKit

enum WheelAlignment{
    case left, center, bottom
}

enum StartAngle {
    case left, center
}

class DialMenuCollectionViewLayout: UICollectionViewFlowLayout {
    
    private struct DashboardMenuMetric {
        static let visiableMenuCount: Int = 5
        static let initialOffset: CGFloat = 2.0
    }
    
    var cellCount:Int = 0
    var center:CGPoint = .zero
    var initialOffset:CGFloat = DashboardMenuMetric.initialOffset
    var offset:CGFloat = 0.0
    
    // initial
    var dialRadius:CGFloat = 119.0
    var angularSpacing:CGFloat = 40.0
    var xOffset:CGFloat = 146.0
    var cellSize:CGSize = CGSize(width: 80.0, height: 80.0)
    var wheelType:WheelAlignment = .bottom
    var itemHeight:CGFloat = 80.0
    
    var visiableCount:Int = DashboardMenuMetric.visiableMenuCount
    var currentIndexPath:IndexPath?
    
    
    var shouldSnap = false
    var shouldFlip = false
    
    var lastVelocity:CGPoint!
    
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var topmostIndexPathBeforeUpdates: IndexPath? = IndexPath(item: 3, section: 0)
    
    init(raduis: CGFloat, angularSpacing: CGFloat, cellSize:CGSize, alignment:WheelAlignment, itemHeight:CGFloat, xOffset:CGFloat, visiableCount: Int) {
        super.init()
        
        self.dialRadius = raduis
        self.angularSpacing = angularSpacing
        self.wheelType = alignment
        self.itemHeight = itemHeight
        self.cellSize = cellSize
        self.itemSize = cellSize
        self.visiableCount = visiableCount
        
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.itemHeight = itemHeight
        self.angularSpacing = angularSpacing
        self.sectionInset = UIEdgeInsets.zero
        self.scrollDirection = .horizontal
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.offset = 0.0
        self.initialOffset = -2.0
        self.scrollDirection = .horizontal
    }
    
    override func prepare(){
        super.prepare()
        self.scrollDirection = .horizontal
        
        if self.collectionView!.numberOfSections > 0 {
            self.cellCount = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        }else{
            self.cellCount = 0
        }
        
        switch cellCount {
        case 1:
            initialOffset = -0.0
        case 2:
            initialOffset = -0.5
        case 3:
            initialOffset = -1.0
        case 4:
            initialOffset = -1.5
        default:
            initialOffset = -2.0
        }
        
        self.offset = (-self.collectionView!.contentOffset.y / self.itemHeight) + initialOffset
        
//        if self.offset <= (-(CGFloat(cellCount) - 3.0)) {
//            self.offset = (-(CGFloat(cellCount) - 3.0))
//        }
//
        print("self.offset = \(self.offset)")
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func getRectForItem(_ itemIndex: Int) -> CGRect{
        let newIndex =  CGFloat(itemIndex) + self.offset
        let scaleFactor = fmax(1, 1 - fabs( newIndex * 0.25))
        let deltaX = self.cellSize.width/2
        
        let temp = Float(self.angularSpacing)
        let dds = Float(self.dialRadius + (deltaX*scaleFactor))
        
        var rX = cosf(temp * Float(newIndex) * Float(Double.pi/180)) * dds
        
        let rY = sinf(temp * Float(newIndex) * Float(Double.pi/180)) * dds
        var oX = -self.dialRadius + self.xOffset - (0.5 * self.cellSize.width);
        let oY = self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y - (0.5 * self.cellSize.height)
        
        
        if(shouldFlip){
            oX = self.collectionView!.frame.size.width + self.dialRadius - self.xOffset - (0.5 * self.cellSize.width)
            rX *= -1
        }
        
        let itemFrame = CGRect(x: oX + CGFloat(rX), y: oY + CGFloat(rY), width: self.cellSize.width, height: self.cellSize.height)
        
        return itemFrame
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var theLayoutAttributes = [UICollectionViewLayoutAttributes]()
        let maxVisiblesHalf:Int = 180 / Int(self.angularSpacing)

        for i in 0 ..< (self.cellCount) {
            let itemFrame = self.getRectForItem(i)
            if(rect.intersects(itemFrame) && i > (-1 * Int(self.offset) - maxVisiblesHalf) && i < (-1 * Int(self.offset) + maxVisiblesHalf)){
                let indexPath = IndexPath(item: i, section: 0)
                let theAttributes = self.layoutAttributesForItem(at: indexPath)
                theLayoutAttributes.append(theAttributes!)
                attributes.append(theAttributes!)
            }
        }
        return theLayoutAttributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if(shouldSnap){
            let index = Int(floor(proposedContentOffset.y / self.itemHeight))
            let off = (Int(proposedContentOffset.y) % Int(self.itemHeight))

            let height = Int(self.itemHeight)

            var targetY = index * height
            if( off > Int((self.itemHeight * 0.5)) && index <= self.cellCount ){
                targetY = (index+1) * height
            }

            return CGPoint(x: proposedContentOffset.x, y: CGFloat(targetY))
        } else {
            print("proposedContentOffset = \(proposedContentOffset)")
            return proposedContentOffset;
        }
    }
    
    
    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    override var collectionViewContentSize : CGSize {
        guard let collectionView = collectionView else { return CGSize(width: 0, height: 0) }
        return CGSize(
        width: collectionView.bounds.size.width,
        height: CGFloat(cellCount - visiableCount) * itemHeight + collectionView.bounds.size.height)
        
//        if scrollDirection == .vertical {
//            return CGSize(
//            width: collectionView.bounds.size.width,
//            height: CGFloat(cellCount - visiableCount) * itemHeight + collectionView.bounds.size.height)
//        } else {
//            return CGSize(
//            width: CGFloat(cellCount - visiableCount) * itemHeight + collectionView.bounds.size.height,
//            height: collectionView.bounds.size.width)
//        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let newIndex = CGFloat(indexPath.item) + self.offset
        
        let theAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        theAttributes.size = self.cellSize
        
        var scaleFactor:CGFloat
        var deltaX:CGFloat
        var translationT:CGAffineTransform
      
        
        //        let degrees = -90.0; //the value in degrees
        //        collectionView.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi/180));
        let rotationValue = self.angularSpacing * newIndex * CGFloat(M_PI/180)
        var rotationT = CGAffineTransform(rotationAngle: rotationValue)
        
        if(shouldFlip){
            rotationT = CGAffineTransform(rotationAngle: -rotationValue)
        }
        
        if( self.wheelType == .left){
            scaleFactor = fmax(0.6, 1 - fabs( CGFloat(newIndex) * 0.25))
            let newFrame = self.getRectForItem(indexPath.item)
            theAttributes.frame = CGRect(x: newFrame.origin.x , y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)
            
            translationT = CGAffineTransform(translationX: 0 , y: 0)
        } else if( self.wheelType == .bottom){
            scaleFactor = fmax(1, 1 - fabs( CGFloat(newIndex) * 0.75))
            let newFrame = self.getRectForItem(indexPath.item)
//            print("index = \(indexPath.row), newFrame = \(newFrame)")
            theAttributes.frame = CGRect(x: newFrame.origin.x , y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)
            
            translationT = CGAffineTransform(translationX: 0 , y: 0)
        } else  {
            scaleFactor = fmax(0.4, 1 - fabs( CGFloat(newIndex) * 0.50))
            deltaX =  self.collectionView!.bounds.size.width / 2
            
            if(shouldFlip){
                theAttributes.center = CGPoint( x: self.collectionView!.frame.size.width + self.dialRadius - self.xOffset , y: self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y)
                
                translationT = CGAffineTransform( translationX: -1 * (self.dialRadius  + ((1 - scaleFactor) * -30)) , y: 0)
                print("should Flip ")
            }else{
                theAttributes.center = CGPoint(x: -self.dialRadius + self.xOffset , y: self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y);
                translationT = CGAffineTransform(translationX: self.dialRadius  + ((1 - scaleFactor) * -30) , y: 0);
                print("should not Flip ")
            }
        }
        
        
        
        let scaleT:CGAffineTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//        theAttributes.alpha = scaleFactor
        theAttributes.isHidden = false
        
        theAttributes.transform = scaleT.concatenating(translationT.concatenating(rotationT))
        
        return theAttributes

    }
    
    func layoutAttributesForHorizontalItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let temp: Double = abs(Double.pi - 0)
        let circumference: CGFloat = CGFloat(temp) * dialRadius;
        let maxNoOfCellsInCircle: CGFloat = circumference / (max(cellSize.width, cellSize.height) + angularSpacing / 2)
        let angleOfEachItem: CGFloat = CGFloat(temp) / maxNoOfCellsInCircle
        
        let newIndex = CGFloat(indexPath.item) + self.offset
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var offset: CGFloat = collectionView?.contentOffset.x ?? 0
        offset = offset == 0 ? 1 : offset
        
        var offsetPartInMPI: CGFloat = offset / circumference
        let angle: CGFloat = CGFloat(2 * Double.pi) * offsetPartInMPI //angularSpacing * newIndex * CGFloat(M_PI)
        var offsetAngle: CGFloat = angle
        
        attributes.size = cellSize
        
        let mirrorX: CGFloat = 1.0
        let mirrorY: CGFloat = 1.0
        
        let x: CGFloat = {
            guard let centerX = collectionView?.center.x else { return 0 }
            let value1 = CGFloat(indexPath.item) * angleOfEachItem
            let value2 = angleOfEachItem / 2
            let value3 = value1 - offsetAngle + value2 - CGFloat(Double.pi)
            let value4 = (dialRadius * value3)
            return (centerX + offset + mirrorX * value4)
        }()
        
        let y: CGFloat = {
            guard let centerY = collectionView?.center.y else { return 0 }
            let value1 = CGFloat(indexPath.item) * angleOfEachItem
            let value2 = angleOfEachItem / 2
            let value3 = value1 - offsetAngle + value2 - CGFloat(Double.pi)
            let value4 = (dialRadius * value3)
            return (centerY + mirrorY * value4)
        }()
        
        let cellCurrentAngle: CGFloat = (CGFloat(indexPath.item) * angleOfEachItem) + angleOfEachItem / 2 - offsetAngle
        
        if cellCurrentAngle >= -angleOfEachItem / 2
            && cellCurrentAngle <= (CGFloat(abs(Double.pi - 0)) + angleOfEachItem / 2) {
            attributes.alpha = 1
        } else {
            attributes.alpha = 0
        }
        
        attributes.center = CGPoint(x: x, y: y)
        attributes.zIndex = cellCount - indexPath.item
        
        attributes.transform = CGAffineTransform(rotationAngle: cellCurrentAngle - CGFloat(Double.pi) / 2)
        
        return attributes
    }
        
//        CGFloat x = _centre.x + offset + mirrorX*(_radius*cosf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - _startAngle));
//        CGFloat y = _centre.y + mirrorY*(_radius*sinf(indexPath.item*angleOfEachItem - offsetAngle + angleOfEachItem/2 - _startAngle));
//        CGFloat cellCurrentAngle = (indexPath.item*angleOfEachItem + angleOfEachItem/2 - offsetAngle);
//        if(cellCurrentAngle >= -angleOfEachItem/2 && cellCurrentAngle <= ABS(_startAngle - _endAngle) + angleOfEachItem/2){
//            attributes.alpha = 1;
//        }else{
//            attributes.alpha = 0;
//        }
//
//        attributes.center = CGPointMake(x, y);
//        attributes.zIndex = cellCount - indexPath.item;
//        if(_rotateItems){
//            if(_mirrorY){
//                attributes.transform = CGAffineTransformMakeRotation(M_PI - cellCurrentAngle - M_PI/2);
//            }else{
//                attributes.transform = CGAffineTransformMakeRotation(cellCurrentAngle - M_PI/2);
//            }
//        }
//        return attributes;
//    }
}
