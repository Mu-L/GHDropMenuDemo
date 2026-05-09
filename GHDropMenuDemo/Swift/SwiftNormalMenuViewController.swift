//
//  SwiftNormalMenuViewController.swift
//

import UIKit

@objc(SwiftNormalMenuViewController)
final class SwiftNormalMenuViewController: GHBaseViewController, GHDropMenuDelegate, GHDropMenuDataSource {

    private var dropMenu: GHDropMenu?

    override func viewDidLoad() {
        super.viewDidLoad()
        let top = view.safeAreaInsets.top
        let dropMenuY = top
        let w = UIScreen.main.bounds.width

        let menu = GHDropMenu.creatDropMenu(
            withConfiguration: nil,
            frame: CGRect(x: 0, y: dropMenuY, width: w, height: 44),
            dropMenuTitleBlock: { [weak self] model in
                self?.navigationItem.title = "筛选结果: \(model.title)"
            },
            dropMenuTagArrayBlock: { [weak self] tags in
                let s = SwiftDropMenuTagResult.summary(from: tags as [Any]?)
                self?.navigationItem.title = "筛选结果: \(s)"
            }
        )
        menu.tableY = dropMenuY + 44
        menu.durationTime = 0.5
        menu.delegate = self
        menu.dataSource = self
        menu.titleSeletedImageName = "up_normal"
        menu.titleNormalImageName = "down_normal"
        view.addSubview(menu)
        dropMenu = menu
    }

    override func back() {
        dropMenu?.close()
        super.back()
    }

    func dropMenu(_ dropMenu: GHDropMenu, dropMenuTitleModel: GHDropMenuModel?) {
        guard let dropMenuTitleModel = dropMenuTitleModel else { return }
        navigationItem.title = "筛选结果: \(dropMenuTitleModel.title)"
    }

    func dropMenu(_ dropMenu: GHDropMenu, tagArray: [Any]?) {
        let s = SwiftDropMenuTagResult.summary(from: tagArray)
        navigationItem.title = "筛选结果: \(s)"
    }

    func columnTitles(inMeun menu: GHDropMenu) -> [Any] {
        ["智能筛选", "价格", "品牌", "时间"]
    }

    func menu(_ menu: GHDropMenu, numberOfColumns columns: Int) -> [Any] {
        switch columns {
        case 0:
            return ["价格从高到低", "价格从低到高", "距离从远到近", "销量从低到高", "信用从高到低"]
        case 1:
            return ["0 - 10 元", "10-20 元", "20-50 元", "50-100 元", "100 - 1000元", "1000 - 10000 元", "10000-100000 元", "100000-500000 元", "500000-1000000 元", "1000000以上"]
        case 2:
            return ["psp", "psv", "nswitch", "gba", "gbc", "gbp", "ndsl", "3ds"]
        default:
            return ["上午", "下午", "早上", "晚上", "清晨", "黄昏"]
        }
    }
}
