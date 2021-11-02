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

class RefreshControlViewController: CMViewController {
    
    var rxColorDataRelay = BehaviorRelay<[UIColor]>.init(value: colorData)
    
    let ivRefresh = UIImageView()
    let vRefresh = UIView()
    
    let scvContainer = UIScrollView()
    let stvContainer = UIStackView()
    
    var flag = false
    var imageAnimation = false
    
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
            $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(10.0)
//            $0.left.equalTo(self.scvIvContainer.snp.right).offset(10.0)
        }

        vRefresh.addSubview(ivRefresh)
        ivRefresh.then {
            $0.image = UIImage(named: "img_review_thumbsdn_s_60")
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
//        print("######## distance = \(distance)")
        
        let offset = -scrollView.contentOffset.y
        
        if imageAnimation == false {
            self.vRefresh.snp.updateConstraints {
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(offset)
            }
            
            print("######################## 높이 값 바꾼다!!")
        }
        
        
        
            let paging = floor(offset/40.0)
            //print("######## contentOffset = \(scrollView.contentOffset)")

            // offset이 50.0 * 서브뷰갯수가 넘어간다면,
            // 200 / 50.0 = 4
            // 250 / 50.0 = 4

            // ((200 / 50.0) % 3)
            let padding = Int(floor((frame/40.0).truncatingRemainder(dividingBy: 9.0)))

//            print("######## padding = \(padding)")

        if imageAnimation == false && flag == false {
            
            if imageData[padding] != self.ivRefresh.image {
                self.ivRefresh.setImage(imageData[padding], animated: true)
            }
        }
        
//        self.ivRefresh.image = UIImage(named: imageData[padding])
//        print("imageData = \(imageData[padding])")

        
        if flag == true && scrollView.contentOffset.y >= -70.0 && scrollView.contentOffset.y <= -60.0 {
            
            
            scrollView.setContentOffset(CGPoint(x: 0.0, y: -60.0), animated: true)
            
            if self.imageAnimation == false {
                
                
                DispatchQueue.main.async {
                    self.ivRefresh.stopAnimating()
                    self.ivRefresh.frame.origin.y = 40.0

                }
                
                self.ivRefresh.layoutIfNeeded()
                
                self.imageAnimation = true
                self.ivRefresh.transition(duration: 0.05, targetImage: imageData[0], completion: {
                    self.imageAnimation = false
                    scrollView.setContentOffset(.zero, animated: true)
                })
                
            }
            
        }
        
        if scrollView.contentOffset == .zero {
            self.imageAnimation = false
        }
    }
    
    // 끝나기 직전
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        //print(#function)
        //print("velocity ===== \(velocity)")
        
        
        
        //        print("#####으아아악 = \(scrollView.contentOffset)")
//        print("#####으아아악2222 = \(targetContentOffset.pointee)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print(#function)
        flag = true
        imageData.shuffle()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print(#function)
        flag = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print(#function)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        //print(#function)
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
        
        print("@@@@@@ duration = \(duration) @@@@@@@")
        print("@@@@@@ 시작할 때 origin 위치 = \(self.frame.origin.y) @@@@@@@")
        var idx = (imageData.firstIndex(of: targetImage) ?? 0) + 1
        self.setImage2(duration: duration, targetImage, animated: true, success: {
                
            if targetImage == imageData[5] {
                    completion()
                    print("completion#######")
                    //print("")
                } else {
                    print("idx = \(idx)#######")
                    self.transition(duration: duration + 0.1, targetImage: imageData[idx], completion: completion)
                }
            })
        
    }
    
    func setImage2(duration: CGFloat, _ image: UIImage?, animated: Bool = true, success: @escaping () -> Void) {

        
        var frame = self.frame
        frame.origin.y = 40
        self.frame = frame
        self.image = image
        self.layoutIfNeeded()
        UIView.transition(with: self, duration: duration, options: .curveLinear, animations: {
            if image == imageData[5] {
                self.frame.origin.y = -10
            } else {
                self.frame.origin.y = -40
            }
            
        }, completion: { voo in
            print("끝날 때 origin 위치 !!!!!!!!!!!!!!!1 \(self.frame.origin.y)")
            if voo == true {
                
                if image != imageData[5] {
                    self.frame.origin.y = 40.0
                    self.layoutIfNeeded()
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
