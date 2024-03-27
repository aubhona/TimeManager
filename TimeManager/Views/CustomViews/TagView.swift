//
//  TagView.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 26.03.2024.
//

import UIKit

public final class TagView: UIView {
    private let circleView = UIView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    private func configureViews() {
        addSubview(circleView)
        circleView.setWidth(10)
        circleView.setHeight(10)
        circleView.layer.cornerRadius = 5
        circleView.pinCenterY(to: self)
        circleView.pinLeft(to: self, 5)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.pinLeft(to: circleView.trailingAnchor, 5)
        titleLabel.pinCenterY(to: self)
        titleLabel.pinRight(to: self, 5)
        titleLabel.font = UIFont.systemFont(ofSize: 15)
    }
    
    public func configure(with title: String, color: UIColor) {
        titleLabel.text = title
        circleView.backgroundColor = color
    }
}

