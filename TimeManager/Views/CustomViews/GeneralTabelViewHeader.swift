//
//  GeneralTabelViewHeader.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//

import UIKit

internal final class GeneralTabelViewHeader: UIView {
    private let openButton = UIButton()
    private let titleLabel = UILabel()
    private var tappedAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    private func configureViews(with widthSize: Double = 100) {
        addSubview(titleLabel)
        titleLabel.pinLeft(to: self, 10)
        titleLabel.pinCenterY(to: self)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        addSubview(openButton)
        openButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        openButton.tintColor = .black
        openButton.pinTop(to: self, 2)
        openButton.pinLeft(to: titleLabel.trailingAnchor, 5)
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
    }
    
    public func configure(with title: String, tappedAction: @escaping () -> Void) {
        titleLabel.removeFromSuperview()
        openButton.removeFromSuperview()
        configureViews(with: (title as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]).width)
        titleLabel.text = title
        self.tappedAction = tappedAction
    }
    
    public func toggleHeader() {
        let startAngle = openButton.isSelected ? CGFloat.pi : 0
        let endAngle = openButton.isSelected ? 0 : CGFloat.pi
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = startAngle
        rotationAnimation.toValue = endAngle
        rotationAnimation.duration = 0.3
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards
        
        openButton.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        openButton.isSelected = !openButton.isSelected
    }
    
    @objc private func openButtonTapped() {
        toggleHeader()
        tappedAction?()
    }
    
}
