//
//  WeekDayCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import UIKit

public final class WeekdayTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "WeekDayViewCell"
    
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
    }
    
    // MARK: - UI Elements
    private let dayLabel: UILabel = UILabel()
    private let dayOfWeekLabel: UILabel = UILabel()
    private let wrapper: UIView = UIView()
    
    public override var isSelected: Bool {
        didSet {
            configureSelectionState()
        }
    }
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureWrapper()
        configureDayLabel()
        configureDayOfWeekLabel()
        clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(day: Int, dayOfWeek: String, isSelected: Bool) {
        
        dayLabel.text = "\(day)"
        dayOfWeekLabel.text = dayOfWeek.uppercased()
        
        
        self.isSelected = isSelected
    }
    
    // MARK: - UI Setup
    private func configureWrapper() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(wrapper)
        wrapper.addSubview(dayLabel)
        wrapper.addSubview(dayOfWeekLabel)
        
        wrapper.backgroundColor = .white
        wrapper.pinHorizontal(to: self, Constants.wrapperOffsetHorizontal)
        wrapper.pinVertical(to: self)
        wrapper.layer.cornerRadius = Constants.wrapperCornerRadius
    }
    
    private func configureDayLabel() {
        dayLabel.font = Constants.font
        dayLabel.textAlignment = .center
        dayLabel.pinCenterX(to: wrapper.centerXAnchor)
        dayLabel.pinCenterY(to: wrapper.centerYAnchor, Constants.dayLabelOffsetY)
    }
    
    private func configureDayOfWeekLabel() {
        dayOfWeekLabel.textAlignment = .center
        dayOfWeekLabel.font = Constants.dayOfWeekFont
        dayOfWeekLabel.pinCenterX(to: wrapper.centerXAnchor)
        dayOfWeekLabel.pinTop(to: dayLabel.bottomAnchor, Constants.dayOfWeekLabelOffsetTop)
    }
    
    private func configureSelectionState() {
        contentView.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.lightGray.cgColor
        dayLabel.textColor = isSelected ? Constants.selectedTextColor : Constants.textColor
        dayOfWeekLabel.textColor = isSelected ? Constants.selectedTextColor : Constants.textColor
        wrapper.backgroundColor = isSelected ? Constants.selectedCellBackgroundColor : Constants.defaultCellBackgroundColor
    }
}
