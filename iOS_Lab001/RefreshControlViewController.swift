//
//  RefreshControlViewController.swift
//  iOS_Lab001
//
//  Created by hyunndy on 2021/10/17.
//

import UIKit
import Then
import SnapKit

class RefreshControlViewController: CMViewController {

    let scvContainer = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vContent.addSubview(scvContainer)
        scvContainer.then {
            $0.alwaysBounceVertical = true
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }
    }
}
