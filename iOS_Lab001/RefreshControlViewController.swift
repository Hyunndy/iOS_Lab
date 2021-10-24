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

class RefreshControlViewController: CMViewController {
    
    var ivRefresh = UIImageView()
    
    var rxColorDataRelay = BehaviorRelay<[UIColor]>.init(value: colorData)
    
    let refreshControl = UIRefreshControl()
    
    let scvContainer = UIScrollView()
    let stvContainer = UIStackView()
    
    override func loadView() {
        super.loadView()
        
        self.vContent.addSubview(scvContainer)
        scvContainer.then {
            $0.delegate = self
            $0.alwaysBounceVertical = true
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.scvContainer.addSubview(stvContainer)
        stvContainer.then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fillEqually
            $0.spacing = 10.0
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.0)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10.0)
            $0.width.equalTo(UIScreen.main.bounds.size.width)
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

//        let vRefresh = UIView()
//        self.refreshControl.addSubview(vRefresh)
        
        self.refreshControl.addSubview(self.ivRefresh)
        self.ivRefresh.then {
            $0.image = UIImage(named: "img_orderlist_new_20")
            $0.contentMode = .scaleToFill
        }.snp.makeConstraints {
            $0.centerX.equalTo(self.refreshControl.frame.width/2)
            $0.centerY.equalTo(0.0)
        }
        
        self.scvContainer.refreshControl = self.refreshControl.then {
            $0.tintColor = .clear
            $0.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        }
        /*
         img_orderlist_check_20
         img_orderlist_new_20
         */

    }
    
    @objc func pullToRefresh() {
        
        // 화면 당김이 임계점을 넘으면 자동으로 beginRefreshing() 메서드 호출
        let colors = self.rxColorDataRelay.value
//
        self.rxColorDataRelay.accept(colors.reversed())
        
        
        // 새로고침이 완료되면 명시적으로 endRefresh() 호출
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rxColorDataRelay.bind(onNext: { [weak self] colors in
            guard let s = self else { return }
            
            for (idx, subView) in s.stvContainer.arrangedSubviews.enumerated() {
                subView.backgroundColor = colors[idx]
            }
                    DispatchQueue.main.async { [weak self] in
                        guard let s = self else { return }
                        s.refreshControl.endRefreshing()
                    }
            
        }).disposed(by: self.disposeBag)
    }
}

extension RefreshControlViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let distance = max(0.0, -(self.refreshControl.frame.origin.y))
        
        print("######## \(distance)")

        self.ivRefresh.snp.updateConstraints {
            $0.centerX.equalTo(self.refreshControl.frame.width/2)
            $0.centerY.equalTo(distance/2)
        }
        
    }
}
