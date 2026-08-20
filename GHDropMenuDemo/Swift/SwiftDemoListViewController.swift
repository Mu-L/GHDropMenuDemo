//
//  SwiftDemoListViewController.swift
//  与 ObjC 首页同一套说明：点进具体文件看最少代码即可照抄。
//

import UIKit

private struct DemoItem {
    let icon: String
    let title: String
    let subtitle: String
    let makeRoot: () -> UIViewController
}

private enum Theme {
    static let background = UIColor(red: 245.0/255, green: 246.0/255, blue: 250.0/255, alpha: 1)
    static let text = UIColor(red: 31.0/255, green: 35.0/255, blue: 51.0/255, alpha: 1)
    static let subtext = UIColor(red: 138.0/255, green: 144.0/255, blue: 166.0/255, alpha: 1)
}

@objc(SwiftDemoListViewController)
final class SwiftDemoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let items: [DemoItem] = [
        DemoItem(
            icon: "🧩",
            title: "复杂筛选菜单",
            subtitle: "Swift 调 GHDropMenu：配置 GHDropMenuModel，见 SwiftComplexMenuViewController.swift",
            makeRoot: { SwiftComplexMenuViewController() }
        ),
        DemoItem(
            icon: "🎚️",
            title: "侧滑筛选菜单",
            subtitle: "全屏侧滑：设置 frame、addSubview 后再 show，见 SwiftSlipMenuViewController.swift",
            makeRoot: { SwiftSlipMenuViewController() }
        ),
        DemoItem(
            icon: "📋",
            title: "普通筛选菜单",
            subtitle: "实现 GHDropMenuDataSource，见 SwiftNormalMenuViewController.swift",
            makeRoot: { SwiftNormalMenuViewController() }
        ),
        DemoItem(
            icon: "📌",
            title: "悬浮筛选（TableView）",
            subtitle: "与 ObjC 共用 GHSuspendViewController，看 Example/吸附筛选菜单/",
            makeRoot: { GHSuspendViewController() }
        ),
        DemoItem(
            icon: "🍔",
            title: "瀑布流 / 美团样式",
            subtitle: "与 ObjC 共用 GHMeituanFoodViewController，看 Example/美团外卖筛选菜单/",
            makeRoot: { GHMeituanFoodViewController() }
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        navigationItem.title = "示例（Swift）"
        navigationItem.largeTitleDisplayMode = .always
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()

        let intro = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        intro.text = "下拉、侧滑、标签、瀑布流筛选菜单演示"
        intro.font = .systemFont(ofSize: 13)
        intro.textColor = Theme.subtext
        intro.textAlignment = .center
        tableView.tableHeaderView = intro

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
        cell.textLabel?.text = "\(item.icon)   \(item.title)"
        cell.textLabel?.textColor = Theme.text
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.text = item.subtitle
        cell.detailTextLabel?.textColor = Theme.subtext
        cell.detailTextLabel?.font = .systemFont(ofSize: 13)
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
