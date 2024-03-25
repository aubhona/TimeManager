//
//  TaskCollectionViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 14.03.2024.
//

import UIKit


class TaskCollectionViewCell: UICollectionViewCell {
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
    
    let timeLabelStart: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        return label
    }()
    
    let timeLabelEnd: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        return label
    }()
    
    let taskWrapperView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = Constants.wrapperCornerRadius
        
        return view
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let checkBox: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        
        button.setImage(UIImage(systemName: "circle", withConfiguration: largeConfig), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: largeConfig), for: .selected)
        button.tintColor = .red
        button.addTarget(self, action: #selector(selectTask), for: .touchUpInside)
        
        return button
    }()
    
    let lineView: UIView = UIView()
    
    var taskSelectAction: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLineView()
        configureTaskWrapperView()
        configureTaskLabel()
        configureCheckBox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configureLineView() {
        addSubview(lineView)
        
        lineView.backgroundColor = .black
        lineView.pinLeft(to: self, 20)
        lineView.pinVertical(to: self, -4)
        lineView.setWidth(Constants.lineWidth)
    }
    
    private func configureTaskWrapperView() {
        addSubview(taskWrapperView)
        
        taskWrapperView.addSubview(taskLabel)
        taskWrapperView.addSubview(checkBox)
        taskWrapperView.backgroundColor = .white
        configureTimeLabels()
        taskWrapperView.pinLeft(to: timeLabelStart.trailingAnchor, 8)
        taskWrapperView.pinRight(to: self, 8)
        taskWrapperView.pinCenterY(to: self)
        taskWrapperView.pinHeight(to: self, 0.8)
    }
    
    private func configureTimeLabels() {
        addSubview(timeLabelStart)
        addSubview(timeLabelEnd)
        
        timeLabelStart.backgroundColor = UIColor("f2f2f7")
        timeLabelEnd.backgroundColor = UIColor("f2f2f7")
        
        timeLabelStart.pinLeft(to: self)
        timeLabelStart.pinTop(to: taskWrapperView)
        timeLabelStart.setWidth(50)
        
        timeLabelEnd.pinLeft(to: self)
        timeLabelEnd.pinBottom(to: taskWrapperView)
        timeLabelEnd.setWidth(50)
    }
    
    private func configureTaskLabel() {
        taskLabel.pinLeft(to: taskWrapperView, 8)
        taskLabel.pinRight(to: taskWrapperView)
        taskLabel.pinCenterY(to: taskWrapperView)
    }
    
    private func configureCheckBox() {
        checkBox.pinRight(to: taskWrapperView)
        checkBox.pinCenterY(to: self)
        checkBox.setHeight(50)
        checkBox.setWidth(50)
    }
    
    private func conifgureSelectionState(isSelected: Bool) {
        taskWrapperView.backgroundColor = isSelected ? UIColor("d4d4de") : .white
        checkBox.isSelected = isSelected
        timeLabelStart.textColor = isSelected ? .lightGray : .black
        timeLabelEnd.textColor = isSelected ? .lightGray : .black
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: taskLabel.text ?? "")
           if isSelected {
               attributeString.addAttribute(
                   NSAttributedString.Key.strikethroughStyle,
                   value: NSUnderlineStyle.single.rawValue,
                   range: NSRange(location: 0, length: attributeString.length))
           }
           
           taskLabel.attributedText = attributeString
    }
    
    public func configure(task: SpecificTaskDto, taskSelectAction: @escaping () -> ()) {
        taskLabel.text = task.name
        timeLabelStart.text = task.scheduledStartTime
        timeLabelEnd.text = task.scheduledEndTime
        conifgureSelectionState(isSelected: task.isCompleted)
        self.taskSelectAction = taskSelectAction
    }
    
    @objc private func selectTask() {
        taskSelectAction?()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.conifgureSelectionState(isSelected: !(self?.checkBox.isSelected ?? true))
            self?.layoutIfNeeded()
        }
    }
}
