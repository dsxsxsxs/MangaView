//
//  ViewController.swift
//  MangaView
//
//  Created by dsxsxsxs on 2020/04/17.
//  Copyright © 2020 dsxsxsxs. All rights reserved.
//

import UIKit

final class ViewController: UITableViewController {
    private let dataSource: [Section] = [
        .regular(.init(pages: [.page, .page])),
        .twoFacing(.init(page: .page)),
        .regular(.init(pages: [.page, .page])),
        .twoFacing(.init(page: .page)),
        .regular(.init(pages: [.page, .page]))
    ]

    private lazy var safeFrame: CGRect = UIApplication.shared.windows.first!.safeAreaLayoutGuide.layoutFrame

    private var twoFacingPageScrollRateObservers: [Int: Holder] = [:]
    private var scrollOffsetObservers: [Int: () -> Void] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TwoFacingPageView.self, forHeaderFooterViewReuseIdentifier: "TwoFacingPageView")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].pages.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch dataSource[section] {
        case .twoFacing:
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TwoFacingPageView") as! TwoFacingPageView
            view.configure(number: section, height: safeFrame.height)
            twoFacingPageScrollRateObservers = twoFacingPageScrollRateObservers.filter { $1.view != view }
            twoFacingPageScrollRateObservers[section] = .init(view: view) {
                view.configure(rate: $0)
            }
            return view
        case .regular:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch dataSource[section] {
        case .twoFacing:
            return UITableView.automaticDimension
        case .regular:
            return CGFloat.leastNonzeroMagnitude
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource[indexPath.section].pages[indexPath.row] {
        case .offset:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OffsetCell", for: indexPath) as! OffsetCell
            let safeFrame = self.safeFrame
            cell.configure(height: safeFrame.height)
            scrollOffsetObservers[indexPath.section] = {[weak self] in
                let rect = tableView.rectForRow(at: indexPath)
                let rectInSuperview = tableView.convert(rect, to: tableView.superview)
                let offsetY = rectInSuperview.minY - safeFrame.minY
                let normalized = max(0, min(offsetY, safeFrame.height))
                self?.twoFacingPageScrollRateObservers[indexPath.section]?.fn(normalized / safeFrame.height)
            }
            return cell
        case .page:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePageCell", for: indexPath) as! SinglePageCell
            cell.configure(number: indexPath.section)
            return cell
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for fn in scrollOffsetObservers.values {
            fn()
        }
    }
}

extension ViewController {
    private enum Section {
        enum Page {
            case offset
            case page
        }
        struct TwoFacingContent {
            let page: Page
            var pages: [Page] {
                [.offset]
            }
        }
        struct RegularContent {
            let pages: [Page]
        }
        case twoFacing(TwoFacingContent)
        case regular(RegularContent)

        var pages: [Page] {
            switch self {
            case .twoFacing(let content):
                return content.pages
            case .regular(let content):
                return content.pages
            }
        }
    }

    private struct Holder {
        let view: UIView
        let fn: (CGFloat) -> Void
    }
}
