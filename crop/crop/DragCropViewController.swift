//
//  DragCropViewController.swift
//  crop
//
//  Created by 马国玺 on 2020/7/26.
//

import UIKit

class DragCropViewController: UIViewController, UICollectionViewDataSource {
    
    let screenWidth = UIScreen.main.bounds.width
    
    lazy var imageArray: Array<UIImage?> = []
    
    lazy var startPoint = CGPoint(x: 0, y: 0)
    
    lazy var cropView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PicCollectionViewCell")
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = floor((screenWidth - 10*4)/3)
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(crop(_:))))
        backImageView.addSubview(cropView)
    }
    @objc func crop(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: backImageView)
        if pan.state == .began {
            startPoint = point
        } else if pan.state == .changed {
            let newOrigin = CGPoint(x: min(point.x, startPoint.x), y: min(point.y, startPoint.y))
            let newSize = CGSize(width: abs(point.x-startPoint.x), height: abs(point.y-startPoint.y))
            let frame = CGRect(origin: newOrigin, size: newSize)
            cropView.frame = frame
        } else if pan.state == .ended {
            let frame = cropView.frame
            if let image = backImageView.image {
                let scale = image.size.width/screenWidth
                let cropImage = image.cropping(to: CGRect(x: frame.origin.x*scale, y: frame.origin.y*scale, width: frame.width*scale, height: frame.height*scale))
                imageArray.insert(cropImage, at: 0)
                collectionView.reloadData()
            }
            
            cropView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicCollectionViewCell", for: indexPath) as! PicCollectionViewCell
        cell.cropImageView.image = imageArray[indexPath.row]
        return cell
    }

}
