//
//  TaskCollectionViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import UIKit


internal final class SpecificTaskCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "TaskCollectionViewCell"
    
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
    
    private var timeLabelStart: UILabel = UILabel()
    private var timeLabelEnd: UILabel = UILabel()
    private var taskWrapperView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var checkBox: UIButton = UIButton()
    private var lineView: UIView = UIView()
    private var taskSelectAction: (() -> ())?
    private var changeBackColor: Bool = false
    private var tagsStackView: UIStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLineView()
        configureTaskWrapperView()
        configureCheckBox()
        configureTaskLabel()
        configureTagsStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureLineView() {
        lineView = UIView()
        
        lineView.backgroundColor = .black
        
        addSubview(lineView)
        lineView.pinLeft(to: self, 20)
        lineView.pinVertical(to: self, -4)
        lineView.setWidth(Constants.lineWidth)
    }
    
    private func configureTaskWrapperView() {
        taskWrapperView = UIView()
        taskWrapperView.layer.cornerRadius = Constants.wrapperCornerRadius
        taskWrapperView.backgroundColor = .white
        
        addSubview(taskWrapperView)
        
        configureTimeLabels()
        
        taskWrapperView.pinLeft(to: timeLabelStart.trailingAnchor, 8)
        taskWrapperView.pinRight(to: self, 8)
        taskWrapperView.pinCenterY(to: self)
        taskWrapperView.pinHeight(to: self, 0.8)
    }
    
    private func configureTimeLabels() {
        timeLabelStart = UILabel()
        timeLabelEnd = UILabel()
        
        timeLabelStart.textAlignment = .center
        timeLabelEnd.textAlignment = .center
        
        addSubview(timeLabelStart)
        addSubview(timeLabelEnd)
        
        timeLabelStart.backgroundColor = UIColor("f2f2f7")
        timeLabelEnd.backgroundColor = UIColor("f2f2f7")
        
        timeLabelStart.pinLeft(to: self)
        timeLabelStart.pinTop(to: taskWrapperView, 5)
        timeLabelStart.setWidth(50)
        
        timeLabelEnd.pinLeft(to: self)
        timeLabelEnd.pinBottom(to: taskWrapperView, 5)
        timeLabelEnd.setWidth(50)
    }
    
    private func configureTaskLabel() {
        titleLabel = UILabel()
        
        taskWrapperView.addSubview(titleLabel)
        
        titleLabel.pinLeft(to: taskWrapperView, 10)
        titleLabel.pinRight(to: checkBox.leadingAnchor)
        titleLabel.pinTop(to: taskWrapperView, 10)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
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
        tagsStackView.pinTop(to: titleLabel.bottomAnchor, 5)
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
        taskWrapperView.backgroundColor = isSelected || changeBackColor ? UIColor("DCDCDC") : .white
        checkBox.isSelected = isSelected
        timeLabelStart.textColor = isSelected || changeBackColor ? .lightGray : .black
        timeLabelEnd.textColor = isSelected || changeBackColor ? .lightGray : .black
    }
    
    public func configure(task: SpecificTaskDto, taskSelectAction: @escaping () -> ()) {
        titleLabel.removeFromSuperview()
        tagsStackView.removeFromSuperview()
        configureTaskLabel()
        configureTagsStackView()
        titleLabel.text = task.name
        timeLabelStart.text = task.scheduledStartTime
        timeLabelEnd.text = task.scheduledEndTime
        self.taskSelectAction = taskSelectAction
        changeBackColor = task.skipped
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
