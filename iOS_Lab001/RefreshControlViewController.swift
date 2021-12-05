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

class AmazingRefreshImageView: UIImageView {
    
    var imageData = [UIImage?]()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AmazingRefreshControl: UIView {
    
    var animalData = [UIImage(named: "01"), UIImage(named: "02"), UIImage(named: "03"), UIImage(named: "04"), UIImage(named: "05"), UIImage(named: "06"), UIImage(named: "07"), UIImage(named: "08"), UIImage(named: "09")]
    
    let ivRefresh = AmazingRefreshImageView()
    let lbRefreshTitle = UILabel()
    let lbLetMeGo = UILabel()
    
    // 새로고침중인지
    var isRefreshing: Bool = false
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .systemRed
        
        self.addSubview(lbRefreshTitle)
        lbRefreshTitle.then {
            $0.text = "땡겨요"
            $0.font = UIFont(name: "BMHANNA11yrsoldOTF", size: 30.0)
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(30.0)
        }
        
        self.addSubview(ivRefresh)
        ivRefresh.then {
            $0.clipsToBounds = true
            $0.imageData = self.animalData
            $0.contentMode = .center
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(lbRefreshTitle.snp.left).offset(-10.0)
        }
        
        let vTest = UIView()
        self.addSubview(vTest)
        vTest.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview()
            $0.height.greaterThanOrEqualTo(200.0)
        }
        
        vTest.addSubview(lbLetMeGo)
        lbLetMeGo.then {
            $0.text = "이제 그만 놔줘요..."
            $0.font = UIFont(name: "BMHANNA11yrsoldOTF", size: 13.0)
            $0.textColor = .white
        }.snp.makeConstraints {
            $0.centerX.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AnimalDataView: UIView {
    let ivAnimal = UIImageView()
    let lbAnimal = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(ivAnimal)
        ivAnimal.then {
            $0.clipsToBounds = true
            $0.contentMode = .center
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-30.0)
        }
        
        self.addSubview(lbAnimal)
        lbAnimal.then {
            $0.font = UIFont(name: "BMEULJIRO", size: 15.0)
            $0.textAlignment = .center
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(30.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RefreshControlViewController: CMViewController {
    
    let animalData = [UIImage(named: "01"), UIImage(named: "02"), UIImage(named: "03"), UIImage(named: "04"), UIImage(named: "05"), UIImage(named: "06"), UIImage(named: "07"), UIImage(named: "08"), UIImage(named: "09")]
    
    let nameData = [UIImage(named: "01") : "병아리", UIImage(named: "02") : "바둑이", UIImage(named: "03") : "판다", UIImage(named: "04") : "곰", UIImage(named: "05") : "돼지", UIImage(named: "06") : "고양이", UIImage(named: "07") : "개구리", UIImage(named: "08") : "코알라", UIImage(named: "09") : "누렁이"]
    
    var rxAnimalRelay = PublishRelay<[UIImage?]>()
    
    let vRefresh = AmazingRefreshControl()
    
    let scvContainer = UIScrollView()
    let stvContainer = UIStackView()
    
    var isDeceleratingAnimating = false
    
    let mint: UIColor = UIColor(red: 0/255, green: 201/255, blue: 161/255, alpha: 1.0)
    
    override func loadView() {
        super.loadView()
        
        self.vContent.backgroundColor = mint
        
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
            $0.clipsToBounds = true
            $0.delegate = self
            $0.alwaysBounceVertical = true
            $0.isPagingEnabled = false
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let vTitle = UIView()
        self.scvContainer.addSubview(vTitle)
        vTitle.then {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
        }.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        let lbTitle = UILabel()
        vTitle.addSubview(lbTitle)
        lbTitle.then {
            $0.text = "최고로 귀여운 동물은?"
            $0.font = UIFont(name: "BMEULJIRO", size: 30.0)
            $0.textAlignment = .center
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.0)
            $0.left.right.bottom.equalToSuperview()
        }
        
        self.scvContainer.addSubview(stvContainer)
        stvContainer.then {
            $0.backgroundColor = .white
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 10.0
        }.snp.makeConstraints {
            $0.top.equalTo(vTitle.snp.bottom)
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
        
        for data in self.animalData {
            
            let vData = AnimalDataView()
            self.stvContainer.addArrangedSubview(vData)
            vData.then {
                $0.layer.cornerRadius = 20.0
                $0.layer.masksToBounds = true
                $0.layer.borderWidth = 1.0
                $0.layer.borderColor = mint.cgColor
                
                $0.ivAnimal.image = data
                $0.lbAnimal.text = self.nameData[data]
            }.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: UIScreen.main.bounds.size.width - 50.0, height: 100.0))
            }
            

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rxAnimalRelay.bind(onNext: { [weak self] data in
            guard let s = self else { return }
            
            for (idx, subView) in s.stvContainer.arrangedSubviews.enumerated() {
                if idx == 0 { continue }
                
                guard let subView = subView as? AnimalDataView else { continue }
            
                subView.ivAnimal.image = data[idx-1]
                subView.lbAnimal.text = s.nameData[data[idx-1]]
            }
            
        }).disposed(by: self.disposeBag)
    }
}

extension RefreshControlViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentOffset.y <= 0.0 else { return }
        
        let frame = self.vRefresh.frame.maxY
        
        if isDeceleratingAnimating == false {
        
            self.vRefresh.snp.updateConstraints {
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(abs(scrollView.contentOffset.y))
            }
        }
        
        let paging = Int(floor((frame/40.0).truncatingRemainder(dividingBy: CGFloat(self.vRefresh.animalData.count))))
        
        if self.vRefresh.isRefreshing == false {
            
            if self.vRefresh.animalData[paging] != self.vRefresh.ivRefresh.image {
                self.vRefresh.ivRefresh.setImage(self.vRefresh.animalData[paging], animated: true)
            }
        }
        
        // 스크롤 놨을 때 느리게 움직이고 애니메이션 진행되는 부분
        if scrollView.isDecelerating == true && scrollView.contentOffset.y >= -70.0 && scrollView.contentOffset.y <= -60.0 {
            
            if self.isDeceleratingAnimating == false {
                
                UIView.animate(withDuration: 0.1, animations: {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -60.0), animated: false)
                    
                    // 높이 조절
                    self.vRefresh.snp.updateConstraints {
                        $0.top.left.right.equalToSuperview()
                        $0.height.equalTo(60.0)
                    }
                    self.vRefresh.layoutIfNeeded()
                })
                
                scrollView.isUserInteractionEnabled = false
                
                self.vRefresh.isRefreshing = true
                self.isDeceleratingAnimating = true
                self.vRefresh.ivRefresh.transition(duration: 0.05, targetImage: self.vRefresh.animalData[0], completion: {
                    self.isDeceleratingAnimating = false
                    scrollView.setContentOffset(.zero, animated: true)
                })
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function)
        if self.isDeceleratingAnimating == false && scrollView.contentOffset == .zero {
            scrollView.isUserInteractionEnabled = true
            self.vRefresh.isRefreshing = false

            self.rxAnimalRelay.accept(self.animalData.shuffled())
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.vRefresh.animalData = self.vRefresh.animalData.ushuffle()
    }
}

extension AmazingRefreshImageView {
    
    // 내려오면서
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
            
            if targetImage == self.imageData[5] {
                completion()
            } else {
                self.transition(duration: duration + 0.1, targetImage: self.imageData[idx], completion: completion)
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
            if image == self.imageData[5] {
                self.frame.origin.y = -10
            } else {
                self.frame.origin.y = -40
            }
            
        }, completion: { voo in
            if voo == true {
                
                if image != self.imageData[5] {
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
