//
//  ViewController.swift
//  CollectionViewDialLayoutDemo
//
//  Created by leechanggwi on 29/02/2020.
//  Copyright © 2020 Lcg5450. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let disposeBag = DisposeBag()
    
    var thumbnailCache: [String: UIImage] = [:]
    var dialLayout: DialMenuCollectionViewLayout!
    var cell_height: CGFloat = 80.0
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var segType:UISegmentedControl!
    
    private var collectionViewBottom: Constraint? = nil
    private var collectionViewWidth: Constraint? = nil
    private var collectionViewHeight: Constraint? = nil
    
    var items = [[String: String]]()
    
    var isOpened: Bool = false
    let openButton: UIButton = {
        let button = UIButton()

        button.setImage(UIImage(named: "happy"), for: .normal)
        button.setImage(UIImage(named: "angry"), for: .selected)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let jsonPath = Bundle.main.path(forResource: "photos", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath!))
        
        do{
            self.items = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [[String : String]]
            
//            let radius = CGFloat(0.39 * 1000)
//            let angularSpacing = CGFloat(0.16 * 90)
//            let xOffset = CGFloat(0.23 * 320)
//            let cell_width = CGFloat(240)
            
            let radius = CGFloat(119.0)
            let angularSpacing = CGFloat(40.0)
            let xOffset = CGFloat(146.0)
            let cell_width = CGFloat(240)
            cell_height = 80
            print("Items :: ", self.items)
            dialLayout = DialMenuCollectionViewLayout(
                raduis: radius,
                angularSpacing: angularSpacing,
                cellSize: CGSize(width: cell_width, height: cell_height),
                alignment: WheelAlignment.bottom,
                itemHeight: cell_height,
                xOffset: xOffset,
                visiableCount: 5)
            
            dialLayout.cellSize = CGSize(width: 80, height: 80)
            dialLayout.wheelType = .bottom
            dialLayout.shouldSnap = false
            dialLayout.shouldFlip = false
            dialLayout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = dialLayout
            
            collectionView.reloadData()
        }catch let err{
            print("Err :: ", err)
        }
        
        view.addSubview(openButton)
        openButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-50)
            maker.width.height.equalTo(100)
        }
        
        openButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.pressedOpenButton()
        })
            .disposed(by: disposeBag)
        
        collectionView.snp.makeConstraints { maker in
            collectionViewBottom = maker.bottom.equalTo(openButton.snp.top).offset(100).constraint
            maker.centerX.equalTo(openButton.snp.centerX)
            collectionViewWidth = maker.width.equalTo(250.0).constraint
            collectionViewHeight = maker.height.equalTo(400.0).constraint
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        collectionView.scrollToItem(at: IndexPath(item: 5, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hideMenuView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func pressedOpenButton() {
        isOpened = !isOpened
        
        if isOpened {
            openButton.isSelected = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.openMenuView()
            }
        } else {
            openButton.isSelected = false
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.hideMenuView()
            }
        }
    }
    
    private func openMenuView() {
        let degrees = -90.0; //the value in degrees
        let rotate = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi/180))
        collectionView.transform = CGAffineTransform.identity.concatenating(rotate)
        collectionView.alpha = 1
    }
    
    private func hideMenuView() {
        let degrees = -90.0; //the value in degrees
        let rotate = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi/180))
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        let move = CGAffineTransform(translationX: 0, y: self.collectionView.frame.height / 2)
        collectionView.transform = rotate.concatenating(scale).concatenating(move)
        collectionView.alpha = 0
//        collectionView.layer.borderColor = UIColor.red.cgColor
//        collectionView.layer.borderWidth = 1
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DialMenuCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DialMenuCollectionViewCell",
            for: indexPath) as? DialMenuCollectionViewCell else {
                return DialMenuCollectionViewCell()
        }
        
        let item = self.items[indexPath.item]
        cell.title = item["name"] ?? ""                
        if let hexString = item["color"] {
            cell.bgColor =  hexStringToUIColor(hexString)
            cell.textColor = .white
        }
    
//        cell.applyBorder(1, borderColor: .white)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select Item :: ", indexPath.item)
        
       //collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
    @IBAction func changeLayoutType(_ sender: AnyObject) {
//        type = segType.selectedSegmentIndex
//        print("TYPE :: ", type)
//        switchExample()
    }
}

