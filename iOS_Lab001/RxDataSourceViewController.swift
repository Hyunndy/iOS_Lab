//
//  Hyunndy_RxDataSourceController.swift
//  ssm-mobile-ios-study
//
//  Created by hyunndy on 2021/10/13.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/*
 필수로 들어가햐는것:
 RxDataSource 사용 +
 섹션 2개 이상 +
 셀 클래스 2개 이상 +
 테이블뷰 or 콜렉션뷰 자유 +
 셀 삭제 & 삽입 기능 +
 디자인&데이터 자유
 */

struct WarriorInfo: IdentifiableType, Equatable {
    var name: String
    var color: String
    
    typealias Identity = String
    var identity: Identity {
        return name
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SectionOfWarrior: AnimatableSectionModelType {
    var identity: Identity {
        return header
    }
    
    var header: String
    var items: [WarriorInfo]

    typealias Identity = String
    typealias Item = WarriorInfo
    
    init(original: SectionOfWarrior, items: [WarriorInfo]) {
        self = original
        self.items = items
    }
    
    init(header: String, items: [WarriorInfo]) {
        self.header = header
        self.items = items
    }
}

let warriorData = [
    SectionOfWarrior(header: "웨딩피치", items: [WarriorInfo(name: "피치", color: "핑크"), WarriorInfo(name: "릴리", color: "갈색"), WarriorInfo(name: "데이지", color: "초록")]),
    SectionOfWarrior(header: "세일러문", items: [WarriorInfo(name: "세일러문", color: "핑크"), WarriorInfo(name: "비너스", color: "노랑"), WarriorInfo(name: "마스", color: "빨강")]),
    SectionOfWarrior(header: "벡터맨", items: [WarriorInfo(name: "타이거", color: "빨강"), WarriorInfo(name: "독수리", color: "노랑"), WarriorInfo(name: "곰", color: "초록")]),
    SectionOfWarrior(header: "파워레인저", items: [WarriorInfo(name: "레드", color: "빨강"), WarriorInfo(name: "옐로우", color: "노랑"), WarriorInfo(name: "그린", color: "초록")])
]

struct SectionOfWarriorIndex {
    static let woman = 0...1
    static let man = 2...3
}

class RxDataSourceViewController: CMViewController {
    
    let btnEdit = UIButton()
    let btnAdd = UIButton()
    let tbvWarrior = UITableView(frame: .zero, style: .grouped)
    
    let rxRelay = BehaviorRelay<[SectionOfWarrior]>(value: warriorData)
    
    override func loadView() {
        super.loadView()
        
        self.vContent.addSubview(btnEdit)
        self.btnEdit.then {
            $0.setTitle("Edit", for: .normal)
            $0.setTitleColor(.blue, for: .normal)
            $0.backgroundColor = .clear
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.0)
            $0.right.equalToSuperview().offset(-10.0)
            $0.size.equalTo(CGSize(width: 100.0, height: 30.0))
        }
        
        self.vContent.addSubview(btnAdd)
        self.btnAdd.then {
            $0.isHidden = true
            $0.setTitle("+", for: .normal)
            $0.setTitleColor(.blue, for: .normal)
            $0.backgroundColor = .clear
        }.snp.makeConstraints { [unowned self] in
            $0.centerY.equalTo(self.btnEdit)
            $0.left.equalToSuperview().offset(10.0)
            $0.size.equalTo(self.btnEdit)
        }
        
        self.vContent.addSubview(tbvWarrior)
        self.tbvWarrior.then {
            $0.register(WomanWarriorTableViewCelll.self, forCellReuseIdentifier: "WomanWarrior")
            $0.register(ManWarriorTableViewCelll.self, forCellReuseIdentifier: "ManWarrior")
        }.snp.makeConstraints { [unowned self] in
            $0.top.equalTo(self.btnEdit.snp.bottom).offset(10.0)
            $0.left.right.bottom.equalToSuperview()
        }
        
        self.setTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.btnEdit.rx.tap.subscribe(onNext: { [weak self] in
            guard let s = self else { return }
            
            s.btnEdit.isSelected = !s.btnEdit.isSelected
            s.btnAdd.isHidden = !s.btnEdit.isSelected
            s.tbvWarrior.setEditing(s.btnEdit.isSelected, animated: true)
//            s.tbvWarrior.reloadData()
            
            
        }).disposed(by: self.disposeBag)
    }
    
    func setTableView() {
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfWarrior>.init(animationConfiguration: AnimationConfiguration(insertAnimation: .right, reloadAnimation: .none, deleteAnimation: .left), configureCell: { dataSource, tableView, indexPath, item in
                
            if SectionOfWarriorIndex.woman.contains(indexPath.section) {
                let warriorCell = tableView.dequeueReusableCell(withIdentifier: "WomanWarrior", for: indexPath) as! WomanWarriorTableViewCelll
                
                warriorCell.lbName.text = item.name
                warriorCell.lbColor.text = item.color
                
                return warriorCell
            } else {
                let warriorCell = tableView.dequeueReusableCell(withIdentifier: "ManWarrior", for: indexPath) as! ManWarriorTableViewCelll
                
                warriorCell.lbName.text = item.name
                warriorCell.lbColor.text = item.color
                
                return warriorCell
            }
        })
        
        dataSource.titleForHeaderInSection = { datasource, index in
            return datasource.sectionModels[index].header
        }
        
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath in
            if self.tbvWarrior.isEditing {
                return true
            } else {
                return false
            }
        }
        
        dataSource.canMoveRowAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        rxRelay
            .bind(to: tbvWarrior.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tbvWarrior.rx.itemDeleted.asDriver()
            .drive(onNext: { [unowned self] indexPath in
                var arr = self.rxRelay.value
                arr[indexPath.section].items.remove(at: indexPath.row)
                rxRelay.accept(arr)
            }).disposed(by: self.disposeBag)
        
        tbvWarrior.rx.itemMoved.asDriver()
            .drive(onNext: { [unowned self] (sourceIdx, destinationIdx) in
                guard sourceIdx != destinationIdx else { return }
                
                var sections = self.rxRelay.value
                var sourceItems = sections[sourceIdx.section].items
                var destinationItems = sections[destinationIdx.section].items
                
                let item = sourceItems.remove(at: sourceIdx.row)
                if sourceIdx.section == destinationIdx.section {
                    destinationItems.remove(at: sourceIdx.row)
                }
                destinationItems.insert(item, at: destinationIdx.row)
                
                let sourceSection = SectionOfWarrior(original: sections[sourceIdx.section], items: sourceItems)
                let destionationSection = SectionOfWarrior(original: sections[destinationIdx.section], items: destinationItems)
                
                sections[sourceIdx.section] = sourceSection
                sections[destinationIdx.section] = destionationSection
                
                let arr = sections
                self.rxRelay.accept(arr)
            }).disposed(by: self.disposeBag)
        
        self.btnAdd.rx.tap.subscribe(onNext: { [weak self] in
            guard let s = self else { return }
            
            let alert = UIAlertController(title: "alert", message: "textField", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (ok) in
                   guard let s = self else { return }
                   
                var arr = s.rxRelay.value
                if arr.contains(where: {$0.header == "신규추가"}) {
                    guard let targetIdx = arr.firstIndex(where: {$0.header == "신규추가"}) else { return }
                    arr[targetIdx].items.insert(WarriorInfo(name: alert.textFields?[0].text ?? "", color: alert.textFields?[0].text ?? ""), at: 0)
                } else {
                    arr.insert(SectionOfWarrior(header: "신규추가", items: [WarriorInfo(name: alert.textFields?[0].text ?? "", color: alert.textFields?[0].text ?? "")]), at: arr.count)
                }
                
                s.rxRelay.accept(arr)
            })
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (cancel) in
                
            })
            
            alert.addAction(cancel)
            alert.addAction(ok)
            alert.addTextField(configurationHandler: nil)
            
            s.present(alert, animated: true, completion: nil)
            
            
        }).disposed(by: self.disposeBag)
        
    }
}

class WomanWarriorTableViewCelll: UITableViewCell {
    
    let lbName = UILabel()
    let lbColor = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(lbName)
        self.lbName.then {
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textAlignment = .center
        }.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(10.0)
        }
        
        self.contentView.addSubview(lbColor)
        self.lbColor.then {
            $0.textColor = .purple
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textAlignment = .center
        }.snp.makeConstraints { [unowned self] in
            $0.top.equalTo(self.lbName.snp.bottom).offset(10.0)
            $0.left.equalToSuperview().offset(10.0)
            $0.bottom.equalToSuperview().offset(-10.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ManWarriorTableViewCelll: UITableViewCell {
    
    let lbName = UILabel()
    let lbColor = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(lbName)
        self.lbName.then {
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textAlignment = .center
        }.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10.0)
            $0.right.equalToSuperview().offset(-10.0)
        }
        
        self.contentView.addSubview(lbColor)
        self.lbColor.then {
            $0.textColor = .purple
            $0.font = .boldSystemFont(ofSize: 20.0)
            $0.textAlignment = .center
        }.snp.makeConstraints { [unowned self] in
            $0.top.equalTo(self.lbName.snp.bottom).offset(10.0)
            $0.right.equalToSuperview().offset(-10.0)
            $0.bottom.equalToSuperview().offset(-10.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
