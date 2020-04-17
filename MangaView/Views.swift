//
//  views.swift
//  MangaView
//
//  Created by dsxsxsxs on 2020/04/17.
//  Copyright © 2020 dsxsxsxs. All rights reserved.
//

import UIKit

final class BigNumberView: UIView {
    @IBOutlet private weak var numberLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.snap(to: self)
    }

    func configure(number: Int) {
        numberLabel.text = "\(number)"
    }
}

final class TwoFacingPageView: UITableViewHeaderFooterView {
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.snap(to: self)
    }

    func configure(number: Int, height: CGFloat) {
        contentLabel.text = "A\(number)B\(number)C\(number)D"
        heightConstraint.constant = height
    }

    func configure(rate: CGFloat) {
        scrollView.contentOffset = CGPoint(x: (scrollView.contentSize.width - scrollView.bounds.width) * rate, y: 0)
    }
}

final class SinglePageCell: UITableViewCell {
    @IBOutlet private weak var numberView: BigNumberView!

    func configure(number: Int) {
        numberView.configure(number: number)
    }
}

final class OffsetCell: UITableViewCell {
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!

    func configure(height: CGFloat) {
        heightConstraint.constant = height
    }
}
