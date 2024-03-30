//
//  GeneralTaskTableViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//

import UIKit

internal final class GeneralTaskTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "GeneralTaskTableViewCell"
    
    private var wrapperView: UIView = UIView ()
    private var titleLabel: UILabel = UILabel()
    private var checkBox: UIButton = UIButton()
    private var progressView = UIProgressView(progressViewStyle: .default)
    private var progressLabel: UILabel = UILabel()
    private var deadlineLabel: UILabel = UILabel()
    private var tagsStackView: UIStackView = UIStackView()
    private var taskSelectAction: (() -> Void)?
    private var changeBackColor: Bool = false
    private var task: GeneralTaskDto?
    private var heightProgressLabelConstraint: NSLayoutConstraint?
    private var heightProgressViewConstraint: NSLayoutConstraint?
    private var topDeadlineLabelConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        wrapperView.removeFromSuperview()
        wrapperView = UIView()
        wrapperView.layer.cornerRadius = 15
        wrapperView.backgroundColor = .white
        contentView.addSubview(wrapperView)
        wrapperView.pin(to: contentView, 10)
        
        configureTaskLabel()
        
        checkBox.removeFromSuperview()
        checkBox = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
        checkBox.setImage(UIImage(systemName: "circle", withConfiguration: largeConfig), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: largeConfig), for: .selected)
        checkBox.tintColor = .red
        checkBox.addTarget(self, action: #selector(selectTask), for: .touchUpInside)
        wrapperView.addSubview(checkBox)
        checkBox.pinRight(to: wrapperView, 10)
        checkBox.pinTop(to: titleLabel, 20)
        checkBox.setHeight(30)
        checkBox.setWidth(30)
        
        progressView.removeFromSuperview()
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.tintColor = .red
        wrapperView.addSubview(progressView)
        progressView.pinCenterY(to: checkBox)
        progressView.pinLeft(to: wrapperView, 10)
        progressView.pinRight(to: checkBox.leadingAnchor, self.bounds.width / 5)
        
        progressLabel.removeFromSuperview()
        progressLabel = UILabel()
        wrapperView.addSubview(progressLabel)
        progressLabel.pinTop(to: progressView.bottomAnchor, 10)
        progressLabel.pinLeft(to: progressView)
        progressLabel.pinRight(to: progressView)
        
        deadlineLabel.removeFromSuperview()
        deadlineLabel = UILabel()
        wrapperView.addSubview(deadlineLabel)
        topDeadlineLabelConstraint = deadlineLabel.pinTop(to: progressLabel.bottomAnchor, 5)
        deadlineLabel.pinLeft(to: progressLabel)
        deadlineLabel.pinRight(to: progressLabel)
        
        configureTagsStackView()
    }
    
    private func configureTaskLabel() {
        titleLabel.removeFromSuperview()
        titleLabel = UILabel()
        wrapperView.addSubview(titleLabel)
        titleLabel.pinTop(to: wrapperView, 10)
        titleLabel.pinLeft(to: wrapperView, 10)
        titleLabel.pinRight(to: wrapperView, 45)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    private func configureTagsStackView() {
        tagsStackView.removeFromSuperview()
        tagsStackView = UIStackView()
        tagsStackView.clearsContextBeforeDrawing = true
        tagsStackView.axis = .vertical
        tagsStackView.clipsToBounds = true
        tagsStackView.distribution = .fillEqually
        wrapperView.addSubview(tagsStackView)
        tagsStackView.pinLeft(to: deadlineLabel)
        tagsStackView.pinRight(to: deadlineLabel)
        tagsStackView.pinTop(to: deadlineLabel.bottomAnchor, 5)
        tagsStackView.pinBottom(to: wrapperView, 10)
    }
    
    public func configure(task: GeneralTaskDto, taskSelectAction: (() -> Void)?) {
        configureViews()
        if (heightProgressViewConstraint != nil) {
            progressView.removeConstraint(heightProgressViewConstraint!)
        }
        if (heightProgressLabelConstraint != nil) {
            progressLabel.removeConstraint(heightProgressLabelConstraint!)
        }
        if (topDeadlineLabelConstraint != nil) {
            deadlineLabel.removeConstraint(topDeadlineLabelConstraint!)
        }
        self.task = task
        titleLabel.text = task.name
        deadlineLabel.text = task.deadlineDate
        progressView.progress = Float(task.doneCount) / Float(task.generalCount)
        progressLabel.text = "Выполнено: \(task.doneCount)/\(task.generalCount)"
        progressLabel.isHidden = task.generalCount == 0
        progressView.isHidden = task.generalCount == 0
        if (progressLabel.isHidden) {
            heightProgressLabelConstraint = progressLabel.setHeight(0)
            heightProgressViewConstraint = progressView.setHeight(0)
            topDeadlineLabelConstraint = deadlineLabel.pinTop(to: titleLabel.bottomAnchor)
        } else {
            topDeadlineLabelConstraint = deadlineLabel.pinTop(to: progressLabel.bottomAnchor, 5)
        }
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
        if (task.tags.count == 1) {
            tagsStackView.distribution = .fill
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
    
    private func conifgureSelectionState(isSelected: Bool) {
        wrapperView.backgroundColor = isSelected || changeBackColor ? UIColor("DCDCDC") : .white
        checkBox.isSelected = isSelected
        guard let task else { return }
        progressLabel.text = "Выполнено: \(isSelected ? task.generalCount : task.doneCount)/\(task.generalCount)"
        progressView.progress = Float(isSelected ? task.generalCount : task.doneCount) / Float(task.generalCount)
        deadlineLabel.textColor = isSelected || changeBackColor ? progressLabel.textColor : task.isFire ? .red : progressLabel.textColor
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
    
    public var isSmall: Bool {
        return progressLabel.isHidden
    }
}
