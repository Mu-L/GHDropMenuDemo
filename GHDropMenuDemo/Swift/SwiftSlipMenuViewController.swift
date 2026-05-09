//
//  SwiftSlipMenuViewController.swift
//

import UIKit

@objc(SwiftSlipMenuViewController)
final class SwiftSlipMenuViewController: GHBaseViewController, GHDropMenuDelegate {

    private var configuration: GHDropMenuModel?
    private weak var dropMenuRef: GHDropMenu?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "筛选", style: .plain, target: self, action: #selector(clickFilter))
        let config = GHDropMenuModel()
        config.recordSeleted = false
        config.titles = config.creaFilterDropMenuData() as! [Any]
        configuration = config
    }

    @objc private func clickFilter() {
        guard let configuration = configuration else { return }
        let menu = GHDropMenu.creatDropFilterMenuWidthConfiguration(configuration) { [weak self] tags in
            let s = SwiftDropMenuTagResult.summary(from: tags as [Any]?)
            self?.navigationItem.title = "筛选结果: \(s)"
        }
        menu.titleSeletedImageName = "up_normal"
        menu.titleNormalImageName = "down_normal"
        menu.delegate = self
        menu.durationTime = 0.5
        menu.frame = view.bounds
        menu.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(menu)
        menu.show()
        dropMenuRef = menu
    }

    func dropMenu(_ dropMenu: GHDropMenu, dropMenuTitleModel: GHDropMenuModel?) {
        guard let dropMenuTitleModel = dropMenuTitleModel else { return }
        navigationItem.title = "筛选结果: \(dropMenuTitleModel.title)"
    }

    func dropMenu(_ dropMenu: GHDropMenu, tagArray: [Any]?) {
        let s = SwiftDropMenuTagResult.summary(from: tagArray)
        navigationItem.title = "筛选结果: \(s)"
    }
}
