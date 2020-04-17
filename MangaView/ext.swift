//
//  ext.swift
//  MangaView
//
//  Created by dsxsxsxs on 2020/04/17.
//  Copyright © 2020 dsxsxsxs. All rights reserved.
//

import UIKit

public extension UIView {
    func snap(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
}
