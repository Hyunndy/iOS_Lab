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

let mint: UIColor = UIColor(red: 0/255, green: 201/255, blue: 161/255, alpha: 1.0)

class AmazingRefreshImageView: UIImageView {
    
    var imageData = [UIImage?]()
    var textData = [UIImage?]()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AmazingRefreshControl: UIView {

    let textData = ["개구리".image(), "누렁이".image(), "판다".image(), "코알라".image(), "고양이".image(), "병아리".image(), "돼지".image(), "곰".image(), "바둑이".image()]
    
    var animalData = [UIImage(named: "01"), UIImage(named: "02"), UIImage(named: "03"), UIImage(named: "04"), UIImage(named: "05"), UIImage(named: "06"), UIImage(named: "07"), UIImage(named: "08"), UIImage(named: "09")] {
        didSet {
            self.ivRefresh.imageData = self.animalData
        }
    }
    
    let ivRefresh = AmazingRefreshImageView()
    let lbRefreshTitle = UILabel()
    let lbLetMeGo = UILabel()
    
    // 새로고침중인지
    var isRefreshing: Bool = false
    
    // 연결되어있는 스크롤뷰의 contentOffset
    var lastScrollViewContentOffset: CGFloat = 0.0
    
    init() {
        super.init(frame: .zero)
        
        self.backgroundColor = .systemRed
        
        self.addSubview(lbRefreshTitle)
        lbRefreshTitle.then {
            $0.text = "귀여워요"
            $0.font = UIFont(name: "BMHANNA11yrsoldOTF", size: 30.0)
        }.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview().offset(30.0)
        }
        
        self.addSubview(ivRefresh)
        ivRefresh.then {
            $0.clipsToBounds = true
            $0.imageData = self.animalData
            $0.textData = self.textData
            $0.contentMode = .right
        }.snp.makeConstraints {
            $0.height.equalTo(40.0)
            $0.width.equalTo(80.0)
            $0.top.bottom.equalToSuperview()
            $0.right.equalTo(lbRefreshTitle.snp.left).offset(-5.0)
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
    
    func checkScrollViewDirection(offset: CGFloat, paging: Int) {
        
        self.ivRefresh.setScrollImage(self.animalData[paging], isUp: self.lastScrollViewContentOffset <= offset)
        
        self.lastScrollViewContentOffset = offset
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
            $0.left.right.bottom.equalToSuperview()
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
        
        print("\(self.vRefresh.lbRefreshTitle.frame.size)")
        print("offset = \(scrollView.contentOffset.y)")
        
        let frame = self.vRefresh.frame.maxY
        let offset = scrollView.contentOffset.y
        
        if isDeceleratingAnimating == false {
        
            self.vRefresh.snp.updateConstraints {
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(abs(offset))
            }
        }
        
        let paging = Int(floor((frame/40.0).truncatingRemainder(dividingBy: CGFloat(self.vRefresh.animalData.count))))
        
        if self.vRefresh.isRefreshing == false {
            
            if self.vRefresh.animalData[paging] != self.vRefresh.ivRefresh.image {
                self.vRefresh.checkScrollViewDirection(offset: offset, paging: paging)
            }
        }
        
        // 스크롤 놨을 때 느리게 움직이고 애니메이션 진행되는 부분
        if scrollView.isDecelerating == true && scrollView.contentOffset.y >= -70.0 && scrollView.contentOffset.y <= -60.0 {
            
            if self.isDeceleratingAnimating == false {
                self.isDeceleratingAnimating = true
            
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
                

                
                // 1. 가만히 있다가 올라감.
                
                self.vRefresh.ivRefresh.startDeceleratingAnimation({
                    self.vRefresh.ivRefresh.transition(duration: 0.05, targetIdx: 0, completion: {
                        self.isDeceleratingAnimating = false
                        scrollView.setContentOffset(.zero, animated: true)
                    })
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
        self.vRefresh.animalData = self.vRefresh.animalData.shuffled()
        self.vRefresh.isRefreshing = true
    }
}

extension AmazingRefreshImageView {
    
    func startDeceleratingAnimation(_ completion: @escaping () -> Void) {
        
        self.frame.origin.y = 0.0
        UIView.transition(with: self, duration: 0.1, options: .curveLinear, animations: {
            self.frame.origin.y = -30.0
        }, completion: { _ in
            completion()
        })
    }
    
    func setScrollImage(_ image: UIImage?, isUp: Bool = true) {
        
        var frame = self.frame
        frame.origin.y = isUp ? 30.0 : -30.0
        self.frame = frame
        UIView.transition(with: self, duration: 0.1, options: .curveLinear, animations: {
            self.frame.origin.y += isUp ? -30.0 : +30.0
            self.image = image
        }, completion: nil)
    }
    
    func transition(duration:CGFloat, targetIdx: Int, completion: @escaping () -> Void) {
        
//        let idx = (imageData.firstIndex(of: targetImage) ?? 0) + 1
        self.setTransitionImage(duration: duration, targetIdx: targetIdx, animated: true, success: {
            
            if targetIdx == 5/*self.imageData[5]*/ {
                completion()
            } else {
                self.transition(duration: duration + 0.1, targetIdx: targetIdx + 1/*self.imageData[idx]*/, completion: completion)
            }
        })
        
    }
    
    func setTransitionImage(duration: CGFloat, targetIdx: Int, animated: Bool = true, success: @escaping () -> Void) {

        
        self.frame.origin.y = 40.0
        self.image = (targetIdx == 5) ? self.textData.randomElement()! : self.imageData[targetIdx]
//        self.image = self.textData.randomElement()!
        
        
        
        UIView.transition(with: self, duration: duration, options: .curveLinear, animations: {
            if targetIdx == 5 {
                self.layoutIfNeeded()
                self.frame.origin.y = -10
            } else {
                self.frame.origin.y = -40
            }
            
        }, completion: { voo in
            if voo == true {
                
                if targetIdx != 5 {
                    self.frame.origin.y = 40.0
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

extension String {

    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image() -> UIImage? {
        var attribute = [NSAttributedString.Key: Any]()
    
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        attribute[.paragraphStyle] = paragraph
        attribute[.foregroundColor] = UIColor.black
        attribute[.font] = UIFont(name: "BMHANNA11yrsoldOTF", size: 30.0)
        
        let origin = CGPoint(x: 0.0, y: 5.0)
        let size = CGSize(width: 80.0, height: 40.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        (self as NSString).draw(in: CGRect(origin: origin, size: size),
                                withAttributes: attribute)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
