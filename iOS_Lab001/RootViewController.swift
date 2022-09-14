//
//  RootViewController.swift
//  iOS_Lab001
//
//  Created by hyunndy on 2021/10/17.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class RootViewController: CMViewController {
    
    let studyData: [String] = ["1: RxDataSource", "2: RefreshControl", "3:Swift Upgrade"]
    
    let tbvContent = UITableView()
    
    override func loadView() {
        super.loadView()
        
        self.vContent.addSubview(tbvContent)
        self.tbvContent.then {
            $0.register(CMTableViewCell.self, forCellReuseIdentifier: "StudyCell")
            $0.estimatedRowHeight = 40.0
        }.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subscribeRx()
    }
    
    private func subscribeRx() {
        
        // 데이터 바인딩
        Observable.just(self.studyData)
        .bind(to: self.tbvContent.rx.items(cellIdentifier: "StudyCell", cellType: CMTableViewCell.self)) { index, data, cell in
            cell.lbTitle.text = data
        }
        .disposed(by: self.disposeBag)
    
        self.tbvContent.rx.itemSelected.bind(onNext: { [weak self] indexPath in
            guard let s = self else { return }

            s.tbvContent.deselectRow(at: indexPath, animated: true)

            switch indexPath.row {
            case 0:
                s.navigationController?.pushViewController(RxDataSourceViewController(), animated: true)
            case 1:
                s.navigationController?.pushViewController(RefreshControlViewController(), animated: true)
            case 2:
                s.navigationController?.pushViewController(TestViewController(), animated: true)
            default:
                break
            }
        }).disposed(by: self.disposeBag)
    }
}

class CMTableViewCell: UITableViewCell {
    
    let lbTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(lbTitle)
        lbTitle.then {
            $0.font = .systemFont(ofSize: 14.0, weight: .semibold)
            $0.textColor = .black
        }.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
