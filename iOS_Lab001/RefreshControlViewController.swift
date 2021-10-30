//
//  RefreshControlViewController.swift
//  iOS_Lab001
//
//  Created by hyunndy on 2021/10/17.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

var colorData: [UIColor] = [.red, .orange, .yellow, .green, .blue, .magenta, .purple]
var imageData: [String] = ["img_orderlist_new_20", "img_orderlist_package_20", "img_orderlist_request_20",
    "img_orderlist_check_20"]

class RefreshControlViewController: CMViewController {
    
    var rxColorDataRelay = BehaviorRelay<[UIColor]>.init(value: colorData)
    
    let ivRefresh = UIImageView()
    let vRefresh = UIView()
    
    let scvContainer = UIScrollView()
    let stvContainer = UIStackView()
    
    let mint: UIColor = UIColor(red: 0/255, green: 201/255, blue: 161/255, alpha: 1.0)
    
    override func loadView() {
        super.loadView()
        
        
        self.navigationController?.navigationBar.barTintColor = mint
        
        
        self.vContent.addSubview(vRefresh)
        vRefresh.then {
            $0.backgroundColor = mint
        }.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.0)
        }
        
        self.vContent.addSubview(scvContainer)
        scvContainer.then { [unowned self] in
            $0.delegate = self
            $0.isPagingEnabled = true
            $0.alwaysBounceVertical = true
            $0.decelerationRate = .fast
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let vTop = UIView()
        self.scvContainer.addSubview(vTop)
        vTop.then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            $0.backgroundColor = mint
            $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(20.0)
        }
        
        self.scvContainer.addSubview(stvContainer)
        stvContainer.then {
            $0.backgroundColor = .white
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 10.0
        }.snp.makeConstraints {
            $0.top.equalTo(vTop.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10.0)
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        let vPadding = UIView()
        stvContainer.addArrangedSubview(vPadding)
        vPadding.then {
            $0.backgroundColor = .white
        }.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(10.0)
        }
        
        for color in colorData {
            let vColor = UIView()
            self.stvContainer.addArrangedSubview(vColor)
            vColor.then {
                $0.layer.cornerRadius = 20.0
                $0.layer.masksToBounds = true
                $0.backgroundColor = color
            }.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: UIScreen.main.bounds.size.width - 50.0, height: 100.0))
                $0.centerX.equalToSuperview()
            }
        }
        //
        
        let lbRefreshTitle = UILabel()
        vRefresh.addSubview(lbRefreshTitle)
        lbRefreshTitle.then {
            $0.text = "땡겨욧"
            $0.font = .systemFont(ofSize: 15.0, weight: .bold)
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
//            $0.left.equalTo(self.scvIvContainer.snp.right).offset(10.0)
        }

        vRefresh.addSubview(ivRefresh)
        ivRefresh.then {
            $0.image = UIImage(named: "img_orderlist_new_20")
            $0.contentMode = .center
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(lbRefreshTitle.snp.left).offset(-10.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rxColorDataRelay.bind(onNext: { [weak self] colors in
            guard let s = self else { return }
            
            for (idx, subView) in s.stvContainer.arrangedSubviews.enumerated() {
                if idx == 0 { continue }
                subView.backgroundColor = colors[idx-1]
            }
            
        }).disposed(by: self.disposeBag)
    }
}

extension RefreshControlViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let frame = self.vRefresh.frame.maxY
        //        let distance = max(0.0, -(frame))
        
        let distance = scrollView.frame.origin.y - self.vRefresh.frame.origin.y
        print("######## distance = \(distance)")
        
        let offset = -scrollView.contentOffset.y
        self.vRefresh.snp.updateConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(offset)
        }
        
            let paging = floor(offset/40.0)
            print("######## paging = \(scrollView.contentOffset)")

            // offset이 50.0 * 서브뷰갯수가 넘어간다면,
            // 200 / 50.0 = 4
            // 250 / 50.0 = 4

            // ((200 / 50.0) % 3)
            let padding = Int(floor((frame/40.0).truncatingRemainder(dividingBy: 4.0)))

            print("######## padding = \(padding)")

        if UIImage(named: imageData[padding]) != self.ivRefresh.image {
            self.ivRefresh.setImage(UIImage(named: imageData[padding]), animated: true)
        }
        
//        self.ivRefresh.image = UIImage(named: imageData[padding])
        print("imageData = \(imageData[padding])")

    }
    
    // 끝나기 직전
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = CGPoint(x: 300.0 , y:300.0 )
        
        print("#####으아아악 = \(scrollView.contentOffset)")
        print("#####으아아악2222 = \(targetContentOffset.pointee)")
    }
}

extension UIImageView{
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.1 : 0.0
        
        var frame = self.frame
        frame.origin.y -= 30
        self.frame = frame
        UIView.transition(with: self, duration: duration, options: .curveLinear, animations: {
            self.frame.origin.y += 30
            self.image = image
        }, completion: nil)
    }
}
