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
    
    var rxColorDataRelay = BehaviorRelay<[UIColor]>.init(value: colorData)
    
    let scvIvContainer = UIScrollView()
    let stvIvContainer = UIStackView()
    let vRefresh = UIView()
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
//
        self.refreshControl.addSubview(vRefresh)
        vRefresh.snp.makeConstraints {
            $0.centerX.equalTo(self.refreshControl.frame.width/2)
            $0.centerY.equalTo(0.0)
            $0.height.equalTo(50.0)
        }


        self.vRefresh.addSubview(scvIvContainer)
        scvIvContainer.then {
            $0.alwaysBounceVertical = true
            $0.contentSize = CGSize(width: 50.0, height: 50.0)
            $0.isUserInteractionEnabled = false
        }.snp.makeConstraints {
            $0.top.bottom.left.equalToSuperview()
            $0.width.equalTo(50.0)
        }

        let stvIvContainer = UIStackView()
        scvIvContainer.addSubview(stvIvContainer)
        stvIvContainer.then {
            $0.axis = .vertical
            $0.spacing = 0.0
            $0.distribution = .fillEqually
        }.snp.makeConstraints {
            $0.top.equalToSuperview()//.offset(25.0)
            $0.left.right.bottom.equalToSuperview()
        }
        
        var padding = UIView()
        stvIvContainer.addArrangedSubview(padding)
        _ = padding.snp.makeConstraints {
//            $0.top.bottom.left.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }

        var ivRefresh = UIImageView()
        stvIvContainer.addArrangedSubview(ivRefresh)
        ivRefresh.then {
            $0.image = UIImage(named: "img_orderlist_check_20")
            $0.contentMode = .scaleToFill
        }.snp.makeConstraints {
//            $0.top.bottom.left.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }

        var ivRefresh2 = UIImageView()
        stvIvContainer.addArrangedSubview(ivRefresh2)
        ivRefresh2.then {
            $0.image = UIImage(named: "img_orderlist_new_20")
            $0.contentMode = .scaleToFill
        }.snp.makeConstraints {
//            $0.top.bottom.left.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }

        var ivRefresh3 = UIImageView()
        stvIvContainer.addArrangedSubview(ivRefresh3)
        ivRefresh3.then {
            $0.image = UIImage(named: "img_orderlist_package_20")
            $0.contentMode = .scaleToFill
        }.snp.makeConstraints {
//            $0.top.bottom.left.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }

        let lbRefreshTitle = UILabel()
        vRefresh.addSubview(lbRefreshTitle)
        lbRefreshTitle.then {
            $0.text = "땡겨욧"
            $0.font = .systemFont(ofSize: 15.0, weight: .bold)
        }.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.left.equalTo(self.scvIvContainer.snp.right).offset(10.0)
        }

        self.scvContainer.refreshControl = self.refreshControl
        _ = self.scvContainer.refreshControl?.then {
            $0.tintColor = .clear
            $0.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        }
//        /*
//         img_orderlist_check_20
//         img_orderlist_new_20
//         */

    }
    
    @objc func pullToRefresh() {
        
        // 화면 당김이 임계점을 넘으면 자동으로 beginRefreshing() 메서드 호출
//        let colors = self.rxColorDataRelay.value
////
//        self.rxColorDataRelay.accept(colors.reversed())
        self.scvContainer.refreshControl?.beginRefreshing()
        
        
        
        // 새로고침이 완료되면 명시적으로 endRefresh() 호출
        DispatchQueue.main.async {
           self.scvContainer.refreshControl?.endRefreshing()
        }
        
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
        
        let frame = self.refreshControl.frame.origin.y
        let distance = max(0.0, -(frame))

//        print("######## \(distance)")

        self.vRefresh.snp.updateConstraints {
            $0.centerX.equalTo(self.refreshControl.frame.width/2)
            $0.centerY.equalTo(distance/2)
        }

//        print("######## RefreshControl FrameSize = \(self.refreshControl.frame.size)")
//        print("######## scrollView = \(scrollView.contentOffset)")
        let offset = -scrollView.contentOffset.y
        let paging = floor(offset/50.0)
        print("######## paging = \(scrollView.contentOffset)")

        // offset이 50.0 * 서브뷰갯수가 넘어간다면,
        // 200 / 50.0 = 4
        // 250 / 50.0 = 4

        // ((200 / 50.0) % 3)
        let padding = floor((frame/50.0).truncatingRemainder(dividingBy: 3.0))

        print("######## padding = \(padding)")
        self.scvIvContainer.contentOffset.y = -(padding * 50.0)



        print("######## scvInvContainer = \(self.scvIvContainer.contentOffset)")
    }
}
