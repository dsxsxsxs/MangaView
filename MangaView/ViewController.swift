//
//  ViewController.swift
//  MangaView
//
//  Created by dsxsxsxs on 2020/04/17.
//  Copyright © 2020 dsxsxsxs. All rights reserved.
//

import UIKit
import Combine

final class ViewController: UITableViewController {
    private let dataSource: [Section] = [
        .regular(.init(pages: [.page, .page])),
        .twoFacing(.init(page: .page)),
        .regular(.init(pages: [.page, .page])),
        .twoFacing(.init(page: .page)),
        .regular(.init(pages: [.page, .page]))
    ]

    private lazy var safeFrame: CGRect = UIApplication.shared.windows.first!.safeAreaLayoutGuide.layoutFrame

    private var tableViewDidScrollEvent = PassthroughSubject<Void, Never>()
    @Published private var twoFacingPageScrollRate = ScrollRate(section: 0, rate: 1)
    private var scrollRateCancellables: [Int: AnyCancellable] = [:]

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
            view.configure(
                number: section,
                height: safeFrame.height,
                rate: self.$twoFacingPageScrollRate.filter { $0.section == section }
                    .map { $0.rate }
                    .eraseToAnyPublisher()
            )
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
            scrollRateCancellables[indexPath.section] = tableViewDidScrollEvent
                .map { _ in
                    let rect = tableView.rectForRow(at: indexPath)
                    let rectInSuperview = tableView.convert(rect, to: tableView.superview)
                    let offsetY = rectInSuperview.minY - safeFrame.minY
                    let normalized = max(0, min(offsetY, safeFrame.height))
                    return .init(section: indexPath.section, rate: normalized / safeFrame.height)
                }
                .assign(to: \.twoFacingPageScrollRate, on: self)
            return cell
        case .page:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePageCell", for: indexPath) as! SinglePageCell
            cell.configure(number: indexPath.section)
            return cell
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewDidScrollEvent.send(())
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

    private struct ScrollRate {
        let section: Int
        let rate: CGFloat
    }
}
