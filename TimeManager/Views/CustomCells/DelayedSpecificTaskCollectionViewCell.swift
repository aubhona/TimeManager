//
//  DelayedSpecificTaskCollectionView.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import UIKit

internal final class DelayedSpecificTaskCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "DelayedSpecificTaskCollectionViewCell"
    
    // MARK: - Constants
    private enum Constants {
        static let cellCornerRadius: CGFloat = 12
        static let selectedCellBackgroundColor: UIColor = .red
        static let defaultCellBackgroundColor: UIColor = .white
        
        static let textColor: UIColor = .red
        static let selectedTextColor: UIColor = .white
        static let font: UIFont = .systemFont(ofSize: 16)
        
        static let dayOfWeekFont: UIFont = .systemFont(ofSize: 12)
        static let dayOfWeekLabelOffsetTop: CGFloat = 2
        
        static let wrapperOffsetHorizontal: CGFloat = 5
        static let wrapperCornerRadius: CGFloat = 10
        
        static let dayLabelOffsetY: CGFloat = -10
        
        static let lineWidth: CGFloat = 2.0
    }
    
    private var taskWrapperView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var durationLabel: UILabel = UILabel()
    private var checkBox: UIButton = UIButton()
    private var taskSelectAction: (() -> ())?
    private var tagsStackView: UIStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTaskWrapperView()
        configureCheckBox()
        configureTaskLabel()
        configureDurationLabel()
        configureTagsStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureTaskWrapperView() {
        taskWrapperView = UIView()
        taskWrapperView.layer.cornerRadius = Constants.wrapperCornerRadius
        taskWrapperView.backgroundColor = .white
        taskWrapperView.clipsToBounds = true
        
        addSubview(taskWrapperView)
        
        taskWrapperView.pinHorizontal(to: self, 10)
        taskWrapperView.pinVertical(to: self)
    }
    
    private func configureTaskLabel() {
        titleLabel = UILabel()
        
        taskWrapperView.addSubview(titleLabel)
        
        titleLabel.pinLeft(to: taskWrapperView, 10)
        titleLabel.pinTop(to: taskWrapperView, 10)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.sizeToFit()
    }
    
    private func configureDurationLabel() {
        durationLabel = UILabel()
        
        taskWrapperView.addSubview(durationLabel)
        
        durationLabel.pinLeft(to: titleLabel.trailingAnchor, 10)
        durationLabel.pinCenterY(to: titleLabel)
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.sizeToFit()
    }
    
    private func configureTagsStackView() {
        tagsStackView = UIStackView()
        tagsStackView.clearsContextBeforeDrawing = true
        tagsStackView.axis = .vertical
        tagsStackView.clipsToBounds = true
        tagsStackView.distribution = .fillEqually
        
        taskWrapperView.addSubview(tagsStackView)
        
        tagsStackView.pinLeft(to: taskWrapperView, 10)
        tagsStackView.pinRight(to: checkBox.leadingAnchor)
        tagsStackView.pinTop(to: durationLabel.bottomAnchor, 5)
        tagsStackView.pinBottom(to: taskWrapperView, 5)
    }
    
    private func configureCheckBox() {
        checkBox = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .large)
        
        checkBox.setImage(UIImage(systemName: "circle", withConfiguration: largeConfig), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: largeConfig), for: .selected)
        checkBox.tintColor = .red
        checkBox.addTarget(self, action: #selector(selectTask), for: .touchUpInside)
        
        taskWrapperView.addSubview(checkBox)
        checkBox.pinRight(to: taskWrapperView)
        checkBox.pinCenterY(to: self)
        checkBox.setHeight(self.bounds.height / 2)
        checkBox.setWidth(self.bounds.height / 2)
    }
    
    private func conifgureSelectionState(isSelected: Bool) {
        taskWrapperView.backgroundColor = isSelected ? UIColor("DCDCDC") : .white
        checkBox.isSelected = isSelected
    }
    
    public func configure(task: SpecificTaskDto, taskSelectAction: @escaping () -> ()) {
        titleLabel.removeFromSuperview()
        tagsStackView.removeFromSuperview()
        durationLabel.removeFromSuperview()
        configureTaskLabel()
        configureDurationLabel()
        configureTagsStackView()
        titleLabel.text = task.name
        durationLabel.text = task.scheduledDate
        self.taskSelectAction = taskSelectAction
        clearTagsStackView()
        for i in 0..<min(task.tags.count, 2) {
            let tag = task.tags[i]
            let tagView = TagView()
            tagView.configure(with: tag.name, color: UIColor(tag.color))
            if i == 1 && task.tags.count > 2 {
                tagView.configure(with: "...", color: .lightGray)
            }
            tagsStackView.addArrangedSubview(tagView)
        }
        
        conifgureSelectionState(isSelected: task.isCompleted)
        animateStrikethrough(isSelected: task.isCompleted)
    }
    
    private func clearTagsStackView() {
        let arrangedSubviews = tagsStackView.arrangedSubviews
        for view in arrangedSubviews {
            tagsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func animateStrikethrough(isSelected: Bool) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.25
        
        titleLabel.layer.add(animation, forKey: CATransitionType.fade.rawValue)

        let attributeString = NSMutableAttributedString(string: titleLabel.text ?? "")

        if isSelected {
            attributeString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: attributeString.length))
            titleLabel.attributedText = attributeString
        } else {
            if let attributedStringText = titleLabel.attributedText {
                let text = attributedStringText.string
                titleLabel.attributedText = nil
                titleLabel.text = text
            }
        }
    }
    
    @objc private func selectTask() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.conifgureSelectionState(isSelected: !(self?.checkBox.isSelected ?? true))
            self?.layoutIfNeeded()
        }
        animateStrikethrough(isSelected: checkBox.isSelected)
        taskSelectAction?()
    }
}
