# GHDropMenu

iOS 筛选菜单（下拉、侧滑、标签等）。**拖文件夹进工程就能用**，演示工程在仓库里可直接运行。

[![platform iOS](https://img.shields.io/badge/platform-iOS-red.svg)](.) [![license MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](.)

- [Flutter 版](https://github.com/shabake/GHDropMenuDemo_flutter)
- [English README](https://github.com/shabake/GHDropMenuDemo/blob/master/README-English.md)

---

## 一、仓库里三样东西（先看懂这个）

| 名字 | 是什么 |
|------|--------|
| **`GHDropMenu/`** | **组件本体**：菜单控件、Cell、模型等。你要集成的是这个文件夹。 |
| **`GHDropMenuDemo/`** | **演示 App**：能跑起来的示例工程（含 Swift 示例）。 |
| **`GHDropMenuDemo/Example/`** | 演示里按场景分的**示例页面代码**，对照下面表格找文件。 |

---

## 二、怎么运行演示

1. 用 Xcode 打开 **`GHDropMenuDemo.xcodeproj`**。  
2. 选中 Target **GHDropMenuDemo**，选一台模拟器，点 Run。  
3. 顶部 **Scheme**（可选）：  
   - **GHDropMenuDemo**：双 Tab（OC 列表 + Swift 列表）。  
   - **GHDropMenuDemo-ObjC** / **GHDropMenuDemo-Swift**：只进对应语言列表。  
   （通过环境变量 `GH_ROOT_DEMO` 切换，详见 Scheme → Run → Environment Variables。）

首页每一行都有**副标题**，说明这个示例是干什么的、该抄哪个文件。

---

## 三、示例对照表（点进 App 里也能看到同样说明）

| 你在列表里点的 | 主要参考代码 |
|----------------|--------------|
| 复杂筛选菜单 | `Example/复杂筛选菜单/GHComplexMenuViewController` · Swift：`Swift/SwiftComplexMenuViewController.swift` |
| 侧滑筛选菜单 | `Example/侧滑筛选菜单/GHSlipMenuViewController` · Swift：`Swift/SwiftSlipMenuViewController.swift` |
| 普通筛选菜单 | `Example/普通筛选菜单/GHNormalMenuViewController` · Swift：`Swift/SwiftNormalMenuViewController.swift` |
| 悬浮筛选（TableView） | `Example/吸附筛选菜单/GHSuspendViewController` |
| 瀑布流 / 美团样式 | `Example/美团外卖筛选菜单/Controller/GHMeituanFoodViewController` |

---

## 四、复制到自己工程：最少三步

1. **把整个 `GHDropMenu` 文件夹**拖进你的 Xcode 工程，勾选 **Copy items**、勾上你的 Target。  
2. 在要用菜单的页面 **`#import "GHDropMenu.h"`**（Swift 用 **Bridging Header** 导入该头文件）。  
3. **照着上表里某一个示例 `.m` / `.swift` 抄**：创建 `GHDropMenu` 或 `GHDropMenuModel`，`addSubview`，需要时调用 `show`。

不需要改你原来的架构；菜单就是一个 `UIView`。

---

## 五、两种用法（别混了）

### A. 普通顶部筛选（带标题栏、下拉）

```objc
GHDropMenu *menu = [GHDropMenu creatDropMenuWithConfiguration:model
                                                        frame:CGRectMake(0, y, width, 44)
                                           dropMenuTitleBlock:^(GHDropMenuModel *m) { /* 选标题 */ }
                                        dropMenuTagArrayBlock:^(NSArray *tags) { /* 侧栏筛选结果 */ }];
[self.view addSubview:menu];
```

弹层会自动挂在当前 window 的容器上，一般不用你管。

### B. 只要全屏侧滑筛选

```objc
GHDropMenu *menu = [GHDropMenu creatDropFilterMenuWidthConfiguration:model
                                            dropMenuTagArrayBlock:^(NSArray *tags) { /* ... */ }];
menu.frame = self.view.bounds;
menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
[self.view addSubview:menu];
[menu show];
```

**必须**：先设好 `frame`、`addSubview`，再 **`show`**。不会自动贴到 window。

---

## 六、返回上一页时

把菜单关掉，避免遮罩留在 window 上：

- Objective-C：`[menu closeMenu];`（在 `viewWillDisappear` 或自定义返回里调一次即可）。  
- Swift：菜单上对应为 **`close()`**（Swift 对 `closeMenu` 的改名）。

---

## 七、环境要求（维护说明）

- **最低系统**：iOS **13.0**。  
- **价格校验**等提示已用 `UIAlertController`。  
- **悬浮列表**里 TableView 的 section 头推荐用可复用的 `GHSuspendMenuHeaderView`（见吸附示例）。

更细的实现说明（如 `ghPopupHostView`）见上文「普通顶部筛选」与侧滑示例源码注释。

---

## 八、动图（效果预览）

![Demo](https://upload-images.jianshu.io/upload_images/1419035-55dd0f6eafb19fd7.gif?imageMogr2/auto-orient/strip)

---

## 联系

如有问题欢迎提 Issue；有帮助可以点个 Star。

