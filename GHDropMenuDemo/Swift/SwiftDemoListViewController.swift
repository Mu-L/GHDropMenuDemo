//
//  SwiftDemoListViewController.swift
//  与 ObjC 首页同一套说明：点进具体文件看最少代码即可照抄。
//

import UIKit

private struct DemoItem {
    let title: String
    let subtitle: String
    let makeRoot: () -> UIViewController
}

@objc(SwiftDemoListViewController)
final class SwiftDemoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let items: [DemoItem] = [
        DemoItem(
            title: "复杂筛选菜单",
            subtitle: "Swift 调 GHDropMenu：配置 GHDropMenuModel，见 SwiftComplexMenuViewController.swift",
            makeRoot: { SwiftComplexMenuViewController() }
        ),
        DemoItem(
            title: "侧滑筛选菜单",
            subtitle: "全屏侧滑：设置 frame、addSubview 后再 show，见 SwiftSlipMenuViewController.swift",
            makeRoot: { SwiftSlipMenuViewController() }
        ),
        DemoItem(
            title: "普通筛选菜单",
            subtitle: "实现 GHDropMenuDataSource，见 SwiftNormalMenuViewController.swift",
            makeRoot: { SwiftNormalMenuViewController() }
        ),
        DemoItem(
            title: "悬浮筛选（TableView）",
            subtitle: "与 ObjC 共用 GHSuspendViewController，看 Example/吸附筛选菜单/",
            makeRoot: { GHSuspendViewController() }
        ),
        DemoItem(
            title: "瀑布流 / 美团样式",
            subtitle: "与 ObjC 共用 GHMeituanFoodViewController，看 Example/美团外卖筛选菜单/",
            makeRoot: { GHMeituanFoodViewController() }
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "示例（Swift）"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: g.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "SwiftDemoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: id)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let vc = item.makeRoot()
        if let base = vc as? GHBaseViewController {
            base.navTitle = item.title
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
