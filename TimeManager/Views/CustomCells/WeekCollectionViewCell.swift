//
//  WeekCollectionViewCell.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 13.03.2024.
//

import UIKit

public final class WeekCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    static let reuseIdentifier: String = "WeekCollectionViewCell"
    
    private var weekTableView: UITableView = UITableView(frame: .zero, style: .plain)
    private var dates: [(Int, String)] = [(Int, String)]()
    private var selectedDay: Int = 1
    private var selectedDayChanged: ((Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(dates: [(Int, String)], index: Int, selectedDayChanged: @escaping (Int) -> ()) {
        self.dates = dates
        weekTableView.rowHeight = self.weekTableView.frame.width / CGFloat(dates.count)
        selectedDay = index
        self.selectedDayChanged = selectedDayChanged
        weekTableView.reloadData()
    }
    
    private func configureTableView() {
        weekTableView = UITableView(frame: bounds, style: .plain)
        weekTableView.register(WeekDayViewCell.self, forCellReuseIdentifier: WeekDayViewCell.reuseIdentifier)
        weekTableView.delegate = self
        weekTableView.dataSource = self
        weekTableView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        weekTableView.frame = contentView.bounds
        weekTableView.separatorStyle = .none
        weekTableView.showsVerticalScrollIndicator = false
        weekTableView.showsHorizontalScrollIndicator = false
        contentView.addSubview(weekTableView)
        weekTableView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        weekTableView.isScrollEnabled = false
        weekTableView.allowsSelection = true
        weekTableView.clipsToBounds = true
        clipsToBounds = true
        weekTableView.allowsSelection = true
        weekTableView.allowsMultipleSelection = false
    }
    
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekDayViewCell.reuseIdentifier, for: indexPath)
        guard let weekDayCell = cell as? WeekDayViewCell else { return cell }
        weekDayCell.configure(day: dates[indexPath.row].0, dayOfWeek: dates[indexPath.row].1, isSelected: indexPath.row == selectedDay)
        weekDayCell.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        return weekDayCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        guard let weekDayCell = tableView.cellForRow(at: indexPath) as? WeekDayViewCell else { return }
        guard let selectedWeekDayCell = tableView.cellForRow(at: IndexPath(row: selectedDay, section: .zero)) as? WeekDayViewCell else { return }
        weekDayCell.isSelected = true
        selectedWeekDayCell.isSelected = false
        selectedDay = indexPath.row
        selectedDayChanged?(selectedDay)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        guard let weekDayCell = tableView.cellForRow(at: indexPath) as? WeekDayViewCell else { return  }
        weekDayCell.isSelected = false
    }
}
