//
//  SearchGeneralTaskTableViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import UIKit


internal final class SearchGeneralTaskTableViewCell: UITableViewCell{
    static let reuseIdentifier: String = "SearchGeneralTaskTableViewCell"
    
    private var wrapperView: UIView = UIView ()
    private var titleLabel: UILabel = UILabel()
    private var progressView = UIProgressView(progressViewStyle: .default)
    private var progressLabel: UILabel = UILabel()
    private var deadlineLabel: UILabel = UILabel()
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
        wrapperView.layer.borderColor = UIColor(.black).cgColor
        wrapperView.layer.borderWidth = 2
        
        configureTaskLabel()
        
        progressView.removeFromSuperview()
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.tintColor = .red
        wrapperView.addSubview(progressView)
        progressView.pinTop(to: titleLabel.bottomAnchor, 10)
        progressView.pinLeft(to: wrapperView, 10)
        progressView.pinRight(to: wrapperView, self.bounds.width / 4)
        
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
    
    public func configure(task: GeneralTaskDto) {
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
    }
    
    public var isSmall: Bool {
        return progressLabel.isHidden
    }
}
