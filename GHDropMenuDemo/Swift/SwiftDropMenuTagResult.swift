//
//  SwiftDropMenuTagResult.swift
//  将筛选 tag 数组整理为展示文案（与 ObjC Demo 逻辑一致）
//

import Foundation

enum SwiftDropMenuTagResult {
    static func summary(from tagArray: [Any]?) -> String {
        guard let models = tagArray as? [GHDropMenuModel] else { return "" }
        var parts: [String] = []
        for m in models {
            if m.tagSeleted, !m.tagName.isEmpty {
                parts.append(m.tagName)
            }
            if !m.maxPrice.isEmpty {
                parts.append("最大价格\(m.maxPrice)")
            }
            if !m.minPrice.isEmpty {
                parts.append("最小价格\(m.minPrice)")
            }
            if !m.singleInput.isEmpty {
                parts.append(m.singleInput)
            }
            if !m.beginTime.isEmpty {
                parts.append("开始时间\(m.beginTime)")
            }
            if !m.endTime.isEmpty {
                parts.append("结束时间\(m.endTime)")
            }
        }
        return parts.joined()
    }
}
