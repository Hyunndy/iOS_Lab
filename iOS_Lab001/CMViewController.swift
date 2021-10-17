//
//  CMViewController.swift
//  iOS_Lab001
//
//  Created by hyunndy on 2021/10/17.
//

import UIKit
import Then
import SnapKit
import RxSwift

class CMViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let statusBarHeight = UIApplication.shared.windows.first { $0.isKeyWindow }?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    let navigationBarHeight = UINavigationController().navigationBar.intrinsicContentSize.height
    
    let vContent = UIView()
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(vContent)
        self.vContent.then {
            $0.backgroundColor = .white
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(statusBarHeight+navigationBarHeight)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
