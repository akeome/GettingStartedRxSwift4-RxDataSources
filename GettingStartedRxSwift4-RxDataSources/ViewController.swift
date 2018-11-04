//
//  ViewController.swift
//  GettingStartedRxSwift4-RxDataSources
//
//  Created by 山下優樹 on 2018/11/04.
//  Copyright © 2018 Yuki Yamashita. All rights reserved.
//

import UIKit
import RxSwift
// UITableView, UICollectionViewをいい感じに更新してくれるライブラリ
import RxDataSources

/**
 SectionModel
 
 RxDataSourceで定義された構造体
 # SettingsSection
 セクションをenumのcaseで定義する
 # SettingsItem
 セクションごとのアイテムを持たせる
 プロパティでcellの高さや、custom cellにしたときの各値を設定できる
 */
typealias SettingsSectionModel = SectionModel<SettingsSection, SettingsItem>

enum SettingsSection {
    // caseが1つのセクション
    case account
    case common
    case other
    
    var headerHeight: CGFloat {
        return 40.0
    }
    
    var footerHeight: CGFloat {
        return 1.0
    }
}

// MARK: - データソース

enum SettingsItem {
    // caseがセクション内のセルデータ群
    // account section
    case account
    case security
    case notification
    case contents
    
    // common section
    case sounds
    case dataUsing
    case accessibility
    
    // other section
    case credits
    case version
    case privacypolicy
    
    // other
    case description(text: String)
    
    var title: String? {
        switch self {
        case .account:
            return "アカウント"
        case .security:
            return "セキュリティ"
        case .notification:
            return "通知"
        case .contents:
            return "コンテンツ設定"
        case .sounds:
            return "サウンド設定"
        case .dataUsing:
            return "データ利用時の設定"
        case .accessibility:
            return "アクセシビリティ"
        case .description:
            return nil
        case .credits:
            return "クレジット"
        case .version:
            return "バージョン"
        case .privacypolicy:
            return "プライバシーポリシー"
        }
        
    }
    
    var rowHeight: CGFloat {
        switch self {
        case .description:
            return 72.0
        default:
            return 48.0
        }
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .description:
            return .none
        default:
            return .disclosureIndicator
        }
        
        
    }
}

// MARK: - ViewModel
class SettingViewModel {
    
    let items = BehaviorSubject<[SettingsSectionModel]>(value: [])
    
    func updateItem() {
        let sections: [SettingsSectionModel] = [
            accountSection(),
            commonSection(),
            otherSection()
        ]
        items.onNext(sections)
        
    }
    
    // セクションごとにメソッド作る(このセクションにはこのitemsが含まれますよ〜と設定してる
    // account
    private func accountSection() -> SettingsSectionModel {
        let items: [SettingsItem] = [
            .account,
            .security,
            .notification,
            .contents
        ]
        return SettingsSectionModel(model: .account, items: items)
        
    }
    
    // セクションごとにメソッド作る
    // common
    private func commonSection() -> SettingsSectionModel {
        let items: [SettingsItem] = [
            .sounds,
            .dataUsing,
            .accessibility,
            .description(text: "基本設定はこの端末でログインしているすべてのアカウントに適用されます")
        ]
        return SettingsSectionModel(model: .common, items: items)
        
    }
    
    // セクションごとメソッド作る
    // other
    private func otherSection() -> SettingsSectionModel {
        let items: [SettingsItem] = [
            .credits,
            .version,
            .privacypolicy
        ]
        return SettingsSectionModel(model: .other, items: items)
    }
    
    
}




// MARK: - ViewController

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var disposeBag = DisposeBag()
    
    /// データソースを指定する
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: configureCell)
    
    /// TableViewCellはこれ
    private lazy var configureCell: RxTableViewSectionedReloadDataSource<SettingsSectionModel>.ConfigureCell = {
        [weak self] (dataSource, tableView, indexPath, _) in
        let item = dataSource[indexPath]
        switch item {
        case .description(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = text
            cell.isUserInteractionEnabled = false
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.accessoryType = item.accessoryType
            return cell
            
        }
        
        
    }
    
    private var viewModel: SettingViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupTableView()
        setupViewModel()
    }
    
    private func setupViewController() {
        navigationItem.title = "設定"
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset.bottom = 12.0
        tableView.backgroundColor = .lightGray
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        // セル選択時の処理はここに書ける
        tableView.rx.itemSelected.subscribe(onNext: {
            [weak self] indexPath in
            guard let item = self?.dataSource[indexPath] else { return }
            self?.tableView.deselectRow(at: indexPath, animated: true)
            
            switch item {
            case .account:
                // 繊維させる処理(省略のためbreak)
                break
            default:
                break
                
            }
        })
        .disposed(by: disposeBag)
        
    }
    
    private func setupViewModel() {
        viewModel = SettingViewModel()
        
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.updateItem()
    }


}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath]
        return item.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = dataSource[section]
        return section.model.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = dataSource[section]
        return section.model.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
}
