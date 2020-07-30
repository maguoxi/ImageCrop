//
//  CropBoxViewController.swift
//  crop
//
//  Created by 马国玺 on 2020/7/27.
//

import UIKit

enum CropPosition: Int {
    case leftTop = 100
    case rightTop = 101
    case leftBottom = 102
    case rightBottom = 103
    case top = 104
    case left = 105
    case bottom = 106
    case right = 107
}

class CropBoxViewController: UIViewController, UICollectionViewDataSource {

    let screenWidth = UIScreen.main.bounds.width
    ///最小裁剪宽度
    let minCropWidth: CGFloat = 100
    ///最小裁剪高度
    let minCropHeight: CGFloat = 100
    
    lazy var imageArray: Array<UIImage?> = []
    
    lazy var cropView: UIView = {
        let frame = CGRect(x: 0, y: 0, width: self.minCropWidth, height: self.minCropHeight)
        let view = UIView(frame: frame)
//        view.backgroundColor = UIColor.red
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(translation(_:))))
        
        let leftTopImage = UIImageView(image: UIImage(named: "corner_left_top"))
        leftTopImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        leftTopImage.autoresizingMask = [.flexibleBottomMargin,.flexibleRightMargin]
        leftTopImage.tag = CropPosition.leftTop.rawValue
        leftTopImage.isUserInteractionEnabled = true
        leftTopImage.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(leftTopImage)
        
        let rightTopImage = UIImageView(image: UIImage(named: "corner_right_top"))
        rightTopImage.frame = CGRect(x: frame.maxX-20, y: 0, width: 20, height: 20)
        rightTopImage.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin]
        rightTopImage.tag = CropPosition.rightTop.rawValue
        rightTopImage.isUserInteractionEnabled = true
        rightTopImage.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(rightTopImage)
        
        let leftBottomImage = UIImageView(image: UIImage(named: "corner_left_bottom"))
        leftBottomImage.frame = CGRect(x: 0, y: frame.maxY-20, width: 20, height: 20)
        leftBottomImage.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin]
        leftBottomImage.tag = CropPosition.leftBottom.rawValue
        leftBottomImage.isUserInteractionEnabled = true
        leftBottomImage.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(leftBottomImage)
        
        let rightBottomImage = UIImageView(image: UIImage(named: "corner_right_bottom"))
        rightBottomImage.frame = CGRect(x: frame.maxX-20, y: frame.maxY-20, width: 20, height: 20)
        rightBottomImage.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin]
        rightBottomImage.tag = CropPosition.rightBottom.rawValue
        rightBottomImage.isUserInteractionEnabled = true
        rightBottomImage.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(rightBottomImage)
        
        let topView = UIView(frame: CGRect(x: 20, y: 0, width: frame.width-20*2, height: 20))
//        topView.backgroundColor = UIColor.green
        topView.tag = CropPosition.top.rawValue
        topView.autoresizingMask = [.flexibleWidth,.flexibleBottomMargin]
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(topView)
        
        let bottomView = UIView(frame: CGRect(x: 20, y: frame.height-20, width: frame.width-20*2, height: 20))
//        bottomView.backgroundColor = UIColor.green
        bottomView.tag = CropPosition.bottom.rawValue
        bottomView.autoresizingMask = [.flexibleWidth,.flexibleTopMargin]
        bottomView.isUserInteractionEnabled = true
        bottomView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(bottomView)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 20, width: 20, height: frame.height-20*2))
//        leftView.backgroundColor = UIColor.green
        leftView.tag = CropPosition.left.rawValue
        leftView.autoresizingMask = [.flexibleHeight,.flexibleRightMargin]
        leftView.isUserInteractionEnabled = true
        leftView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(leftView)
        
        let rightView = UIView(frame: CGRect(x: frame.width-20, y: 20, width: 20, height: frame.height-20*2))
//        rightView.backgroundColor = UIColor.green
        rightView.tag = CropPosition.right.rawValue
        rightView.autoresizingMask = [.flexibleHeight,.flexibleLeftMargin]
        rightView.isUserInteractionEnabled = true
        rightView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move(_:))))
        view.addSubview(rightView)
        
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
        
        backImageView.addSubview(cropView)
        cropView.center = backImageView.center
        
        resetCropMask()
    }
    @objc func translation(_ pan: UIPanGestureRecognizer) {
        var point = pan.location(in: self.backImageView)
        if point.x < 0 {point.x = 0}
        if point.x > backImageView.frame.width {point.x = backImageView.frame.width}
        if point.y < 0 {point.y = 0}
        if point.y > backImageView.frame.height {point.y = backImageView.frame.height}
        
        if pan.state == .changed {
            var frame = cropView.frame
            let minX: CGFloat = 0.0
            let minY: CGFloat = 0.0
            let maxX = backImageView.frame.width-frame.width
            let maxY = backImageView.frame.height-frame.height
            var x = point.x-frame.width/2
            if x < minX {
                x = minX
            }
            if x > maxX {
                x = maxX
            }
            var y = point.y-frame.height/2
            if y < minY {
                y = minY
            }
            if y > maxY {
                y = maxY
            }
            frame.origin.x = x
            frame.origin.y = y
            cropView.frame = frame
            resetCropMask()
        }
    }
    @objc func move(_ pan: UIPanGestureRecognizer) -> Void {
        guard let panView = pan.view else { return }
        
        var point = pan.location(in: self.backImageView)
        if point.x < 0 {point.x = 0}
        if point.x > backImageView.frame.width {point.x = backImageView.frame.width}
        if point.y < 0 {point.y = 0}
        if point.y > backImageView.frame.height {point.y = backImageView.frame.height}
        
        if pan.state == .changed {
            if panView.tag == CropPosition.leftTop.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = 0.0
                let minY: CGFloat = 0.0
                let maxX = frame.maxX-minCropWidth
                let maxY = frame.maxY-minCropHeight
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: x, y: y, width: (frame.origin.x-x)+frame.width, height: (frame.origin.y-y)+frame.height)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.left.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = 0.0
                let maxX = frame.maxX-minCropWidth
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                frame = CGRect(x: x, y: frame.origin.y, width: (frame.origin.x-x)+frame.width, height: frame.height)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.leftBottom.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = 0.0
                let minY: CGFloat = frame.minY+minCropHeight
                let maxX = frame.maxX-minCropWidth
                let maxY = backImageView.frame.height
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: x, y: frame.origin.y, width: (frame.origin.x-x)+frame.width, height: y-frame.origin.y)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.top.rawValue {
                var frame = cropView.frame
                let minY: CGFloat = 0.0
                let maxY = frame.maxY-minCropHeight
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: (frame.origin.y-y)+frame.height)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.rightTop.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = frame.minX+minCropWidth
                let minY: CGFloat = 0.0
                let maxX = backImageView.frame.width
                let maxY = frame.maxY-minCropHeight
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: frame.origin.x, y: y, width: x-frame.origin.x, height: (frame.origin.y-y)+frame.height)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.right.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = frame.minX+minCropWidth
                let maxX = backImageView.frame.width
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: x-frame.origin.x, height: frame.height)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.rightBottom.rawValue {
                var frame = cropView.frame
                let minX: CGFloat = frame.minX+minCropWidth
                let minY: CGFloat = frame.minY+minCropHeight
                let maxX = backImageView.frame.width
                let maxY = backImageView.frame.height
                var x = point.x
                if x < minX {
                    x = minX
                }
                if x > maxX {
                    x = maxX
                }
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: x-frame.origin.x, height: y-frame.origin.y)
                cropView.frame = frame
                resetCropMask()
            } else if panView.tag == CropPosition.bottom.rawValue {
                var frame = cropView.frame
                let minY: CGFloat = frame.minY+minCropHeight
                let maxY = backImageView.frame.height
                var y = point.y
                if y < minY {
                    y = minY
                }
                if y > maxY {
                    y = maxY
                }
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: y-frame.origin.y)
                cropView.frame = frame
                resetCropMask()
            }
        }
    }
    
    func resetCropMask() -> Void {
        let path = UIBezierPath(rect: self.backImageView.bounds)
        let clearPath = UIBezierPath(rect: self.cropView.frame)
        path.append(clearPath)

        let layer = CAShapeLayer()
        layer.frame = self.backImageView.bounds
        layer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillRule = .evenOdd
        layer.path = path.cgPath
        for item in backImageView.layer.sublayers ?? [] {
            if item is CAShapeLayer {
                item.removeFromSuperlayer()
            }
        }
        self.backImageView.layer.addSublayer(layer)
    }

    @IBAction func cropClicked(_ sender: Any) {
        let frame = cropView.frame
        if let image = backImageView.image {
            let scale = image.size.width/screenWidth
            let cropImage = image.cropping(to: CGRect(x: frame.origin.x*scale, y: frame.origin.y*scale, width: frame.width*scale, height: frame.height*scale))
            imageArray.insert(cropImage, at: 0)
            collectionView.reloadData()
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
