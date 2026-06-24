我非常赞同先做架构文档，而且这是我们整个项目最重要的一步。

不过，我先纠正一下我们前面讨论中的一个方向。

我们之前一直参考的是”大厂风格”。

但是如果目标是做一个以后几年都能一直维护的 UIKit Collection 框架，Apple Framework 的设计比国内大厂更值得参考。

例如：

* AVFoundation
* CoreData
* Combine
* SwiftUI
* UICollectionViewDiffableDataSource

它们都有几个共同特点：

* 泛型优先，而不是业务模型优先。
* Protocol 优先，而不是继承优先。
* Coordinator 负责协调，不负责业务。
* Builder 负责创建，不负责生命周期。
* Event 与 State 分离。

所以，我准备把整个框架重新设计成Apple Framework 风格，同时保持 MVVM 易用性。

⸻

HXCollectionKit v1.0 架构设计文档

一、设计目标

Primary Goal

打造一个：

可长期维护、业务无关、UIKit 原生、Swift Concurrency、MVVM 友好的 Collection Framework

不是 Demo。

不是模板。

而是 Foundation。

⸻

二、设计原则

1. Single Responsibility

每个对象只负责一件事情。

例如：

CollectionCoordinator
只负责协调
──────────────
CollectionDataSource
只负责 Diffable
──────────────
RegistrationCenter
只负责注册 Cell
──────────────
LayoutBuilder
只负责 Layout
──────────────
SnapshotBuilder
只负责 Snapshot

⸻

2. Dependency Direction

所有依赖必须单向。

Business
↓
Coordinator
↓
DataSource
↓
UIKit

绝不能：

DataSource
↓
ViewModel

⸻

3. Generic First

整个框架不允许出现：

DemoItem
HomeItem
VideoItem

全部泛型。

例如：

CollectionCoordinator<
Section,
Item
>

⸻

4. UIKit Isolation

UIKit 只允许存在于：

Core
Layout
Registration

业务层：

不能直接操作：

UICollectionView
Diffable
CellRegistration

⸻

三、整体架构

                    Business Layer
                          │
                          ▼
                  CollectionCoordinator
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼
 CollectionDelegate  CollectionDataSource  RegistrationCenter
          │               │                │
          └───────────────┼────────────────┘
                          ▼
                  SnapshotBuilder
                          │
                          ▼
                 UICollectionView

⸻

四、目录

HXCollectionKit
│
├── Core
│
├── Snapshot
│
├── Registration
│
├── Layout
│
├── Provider
│
├── Event
│
├── Menu
│
├── DragDrop
│
├── Prefetch
│
├── Animation
│
└── Utilities

⸻

五、模块职责

⸻

Core

核心协调层。

负责：

Coordinator
DataSource
Delegate
生命周期

禁止：

Layout
Menu
业务

⸻

Snapshot

负责：

State
↓
Snapshot

禁止：

UICollectionView

⸻

Layout

负责：

CompositionalLayout

支持：

Grid
List
Horizontal
Waterfall
Custom

⸻

Registration

负责：

CellRegistration
HeaderRegistration
FooterRegistration
Decoration

⸻

Provider

负责：

CellProvider
HeaderProvider
FooterProvider

⸻

Event

统一事件。

例如：

didSelect
didMove
didDelete
didScroll
didPrefetch

⸻

Menu

负责：

ContextMenu
Preview
Actions

⸻

DragDrop

负责：

Drag
Drop
Move

⸻

Prefetch

负责：

图片预加载
视频预加载
分页

⸻

Animation

负责：

reload
move
insert
delete
reconfigure

⸻

六、协议关系

CollectionCoordinator
        │
        ▼
CollectionDataSourceProtocol
        │
        ▼
SnapshotBuilderProtocol
──────────────
CollectionDelegateProtocol
──────────────
RegistrationProtocol
──────────────
LayoutProviderProtocol
──────────────
CellProviderProtocol

所有模块通过 Protocol 通信。

⸻

七、核心泛型

整个框架：

只有两个泛型。

Section
Item

所有对象：

CollectionCoordinator<
Section,
Item
>
CollectionDataSource<
Section,
Item
>
SnapshotBuilder<
Section,
Item
>
CellProvider<
Item
>
LayoutProvider<
Section>

没有：

HomeItem
VideoItem

⸻

八、Snapshot

Snapshot：

统一类型。

typealias Snapshot =
NSDiffableDataSourceSnapshot<
Section,
Item
>

整个框架：

禁止再次声明：

Snapshot2
HomeSnapshot

⸻

九、生命周期

Coordinator：

bind()
↓
register()
↓
configureLayout()
↓
apply(snapshot)
↓
listenEvents()
↓
destroy()

⸻

十、公开 API

业务层：

理想情况下：

只有这些 API。

coordinator.bind(
    to: collectionView
)
coordinator.apply(snapshot)
coordinator.reload()
coordinator.scrollTo(item)
coordinator.select(item)
coordinator.deselect(item)

整个业务：

不会出现：

UICollectionViewDiffableDataSource

⸻

十一、事件系统

统一：

enum CollectionEvent<Item> {
    case didSelect(Item)
    case didDeselect(Item)
    case didMove(Item)
    case didDelete(Item)
    case willDisplay(Item)
    case didEndDisplay(Item)
    case didScroll(CGPoint)
    case prefetch([Item])
}

以后：

Coordinator：

只暴露：

eventHandler

⸻

十二、数据流

整个框架：

永远：

单向。

User
↓
UICollectionView
↓
Coordinator
↓
Event
↓
ViewModel
↓
Repository
↓
State
↓
SnapshotBuilder
↓
Snapshot
↓
Coordinator
↓
UICollectionView

没有任何反向引用。

⸻

十三、为什么没有 Adapter？

这里我要修正我们前面的一个设计。

我之前提到过 Adapter 层，希望以后同时支持 UITableView 和 UICollectionView。

我现在不建议在 v1.0 做。

原因：

* UICollectionView 和 UITableView 在布局、补充视图、拖拽等能力上差异很大。
* 为了统一而统一，会引入大量条件分支和抽象成本。
* 现代 UIKit 中，UICollectionView 已经可以覆盖绝大多数 UITableView 的使用场景。

因此，我建议 v1.0 专注于 UICollectionView，把 Adapter 放到 v2.0 再考虑。

⸻

v1.0 最终目标

最终，业务层应该能够写出这样的代码：

let coordinator = CollectionCoordinator<HomeSection, HomeItem>()
coordinator.bind(to: collectionView)
coordinator.register(HomeCell.self)
coordinator.setLayout(.list())
coordinator.setCellProvider(homeCellProvider)
viewModel.onSnapshot = { [weak coordinator] snapshot in
    coordinator?.apply(snapshot)
}
coordinator.onEvent = { event in
    // 处理点击、拖拽、菜单等事件
}

业务代码无需直接接触 UICollectionViewDiffableDataSource、CellRegistration、UICollectionViewDelegate 等底层细节。

⸻

我建议的下一步

不要先写 CollectionCoordinator。

正确顺序应该是：

1. 定义所有公共协议（Protocols）
2. 定义所有公共类型（Event、Environment、Configuration）
3. 定义 CollectionCoordinator 对外 API
4. 最后才实现 CollectionCoordinator

这样 Core 层的 API 会稳定，后面的实现基本不会返工。这也是苹果框架和成熟开源库常用的开发方式。
