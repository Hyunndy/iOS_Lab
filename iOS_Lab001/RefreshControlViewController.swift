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
var imageData: [UIImage?] = [UIImage(named: "01"), UIImage(named: "02"), UIImage(named: "03"), UIImage(named: "04"), UIImage(named: "05"), UIImage(named: "06"), UIImage(named: "07"), UIImage(named: "08"), UIImage(named: "09")]

class AmazingRefreshControl: UIView {
    
    let ivRefresh = UIImageView()
    let lbRefreshTitle = UILabel()
    let lbLetMeGo = UILabel()
    
    // 새로고침중인지
    var isRefreshing: Bool = false
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .systemRed
        
        self.addSubview(lbRefreshTitle)
        lbRefreshTitle.then {
            $0.text = "땡겨욧"
            $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(10.0)
        }
        
        self.addSubview(ivRefresh)
        ivRefresh.then {
            $0.contentMode = .center
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(lbRefreshTitle.snp.left).offset(-10.0)
        }
        
        let vTest = UIView()
        self.addSubview(vTest)
        vTest.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200.0)
            $0.left.right.bottom.equalToSuperview()
        }
        
        vTest.addSubview(lbLetMeGo)
        lbLetMeGo.then {
            $0.text = "이제 그만 놔줘요..."
            $0.font = .systemFont(ofSize: 10.0, weight: .bold)
        }.snp.makeConstraints {
            $0.centerX.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RefreshControlViewController: CMViewController {
    
    var rxColorDataRelay = BehaviorRelay<[UIColor]>.init(value: colorData)
    
    
    let vRefresh = AmazingRefreshControl()
    
    let scvContainer = UIScrollView()
    let stvContainer = UIStackView()
    
    var flag = false
    var isDeceleratingAnimating = false
    
    let mint: UIColor = UIColor(red: 0/255, green: 201/255, blue: 161/255, alpha: 1.0)
    
    override func loadView() {
        super.loadView()
        
        self.navigationController?.navigationBar.barTintColor = mint
        
        self.vContent.addSubview(vRefresh)
        vRefresh.then {
            $0.backgroundColor = .systemRed
        }.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(0.0)
        }
        
        self.vContent.addSubview(scvContainer)
        scvContainer.then { [unowned self] in
            $0.delegate = self
            $0.alwaysBounceVertical = true
            $0.isPagingEnabled = false
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
        let offset = -scrollView.contentOffset.y
        
        if isDeceleratingAnimating == false {
    
                // 높이 조절
                self.vRefresh.snp.updateConstraints {
                    $0.top.left.right.equalToSuperview()
                    $0.height.equalTo(offset)
                }
            
            print("#### Hyunndy Test 높이 = \(offset)")
            if offset > 200.0 {
                
            }
            
        }
        
        let paging = Int(floor((frame/40.0).truncatingRemainder(dividingBy: CGFloat(imageData.count))))
        
        if self.vRefresh.isRefreshing == false {
            
            if imageData[paging] != self.vRefresh.ivRefresh.image {
                self.vRefresh.ivRefresh.setImage(imageData[paging], animated: true)
            }
        }
        
        // 스크롤 놨을 때 느리게 움직이고 애니메이션 진행되는 부분
        if scrollView.isDecelerating == true && scrollView.contentOffset.y >= -70.0 && scrollView.contentOffset.y <= -60.0 {
            
            scrollView.setContentOffset(CGPoint(x: 0.0, y: -60.0), animated: true)
            
            if self.isDeceleratingAnimating == false {
                
                scrollView.isUserInteractionEnabled = false
                
                
                DispatchQueue.main.async {
                    self.vRefresh.ivRefresh.stopAnimating()
                    self.vRefresh.ivRefresh.frame.origin.y = 40.0
                    
                }
                
//                self.ivRefresh.layoutIfNeeded()
                
                self.vRefresh.isRefreshing = true
                self.isDeceleratingAnimating = true
                self.vRefresh.ivRefresh.transition(duration: 0.05, targetImage: imageData[0], completion: {
                    self.isDeceleratingAnimating = false
                    scrollView.setContentOffset(.zero, animated: true)
                })
            }
        }
        
        
//
//        if scrollView.contentOffset == .zero {
//            self.isAnimating = false
//        }
    }
    
    // 끝나기 직전
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function)
        if self.isDeceleratingAnimating == false && scrollView.contentOffset == .zero {
            scrollView.isUserInteractionEnabled = true
            self.vRefresh.isRefreshing = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        flag = true
        imageData.shuffle()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        flag = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
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
    
    func transition(duration:CGFloat, targetImage: UIImage?, completion: @escaping () -> Void) {
        
        var idx = (imageData.firstIndex(of: targetImage) ?? 0) + 1
        self.setImage2(duration: duration, targetImage, animated: true, success: {
            
            if targetImage == imageData[5] {
                completion()
            } else {
                self.transition(duration: duration + 0.1, targetImage: imageData[idx], completion: completion)
            }
        })
        
    }
    
    func setImage2(duration: CGFloat, _ image: UIImage?, animated: Bool = true, success: @escaping () -> Void) {
        
        
        var frame = self.frame
        frame.origin.y = 40
        self.frame = frame
        self.image = image
//        self.layoutIfNeeded()
        UIView.transition(with: self, duration: duration, options: .curveLinear, animations: {
            if image == imageData[5] {
                self.frame.origin.y = -10
            } else {
                self.frame.origin.y = -40
            }
            
        }, completion: { voo in
            if voo == true {
                
                if image != imageData[5] {
                    self.frame.origin.y = 40.0
//                    self.layoutIfNeeded()
                    success()
                } else {
                    UIView.transition(with: self, duration: 0.3, options: .curveLinear, animations: {
                        self.frame.origin.y = 0.0
                    }, completion: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            success()
                        })
                    })
                    
                }
            }
        })
    }
}
