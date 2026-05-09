//
//  SwiftComplexMenuViewController.swift
//

import UIKit

@objc(SwiftComplexMenuViewController)
final class SwiftComplexMenuViewController: GHBaseViewController, GHDropMenuDelegate {

    private var dropMenu: GHDropMenu?

    override func viewDidLoad() {
        super.viewDidLoad()
        let top = view.safeAreaInsets.top
        let label = UILabel(frame: CGRect(x: 0, y: top, width: UIScreen.main.bounds.width, height: 44))
        label.text = "样式1 (Swift)"
        label.textColor = .white
        view.addSubview(label)

        let configuration = GHDropMenuModel()
        configuration.recordSeleted = false
        configuration.titles = configuration.creaDropMenuData() as! [Any]

        let dropMenuY = top + 44
        let w = UIScreen.main.bounds.width

        let menu = GHDropMenu.creatDropMenu(
            withConfiguration: configuration,
            frame: CGRect(x: 0, y: dropMenuY, width: w, height: 44),
            dropMenuTitleBlock: { [weak self] model in
                self?.navigationItem.title = "筛选结果: \(model.title)"
            },
            dropMenuTagArrayBlock: { [weak self] tags in
                self?.applyTagSummary(tags as [Any]?)
            }
        )
        menu.tableY = dropMenuY + 44
        menu.titleSeletedImageName = "up_normal"
        menu.titleNormalImageName = "down_normal"
        menu.delegate = self
        menu.durationTime = 0.5
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
        applyTagSummary(tagArray)
    }

    private func applyTagSummary(_ tagArray: [Any]?) {
        let s = SwiftDropMenuTagResult.summary(from: tagArray)
        navigationItem.title = "筛选结果: \(s)"
    }
}
