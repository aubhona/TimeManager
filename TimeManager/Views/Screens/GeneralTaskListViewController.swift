//
//  GeneralTaskListViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 28.03.2024.
//

import UIKit

internal final class GeneralTaskListViewController: UIViewController {
    private var generalTaskTableView: UITableView = UITableView(frame: .zero)
    private var addButton: UIBarButtonItem = UIBarButtonItem()
    private var calendarButton: UIBarButtonItem = UIBarButtonItem()
    private var filterButton: UIBarButtonItem = UIBarButtonItem()
    private var titleLabel: UILabel = UILabel()
    private var presenter: GeneralTaskListPresenter?
    private var smallCells: [[Bool]] = [[Bool]]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("f2f2f7")
        presenter = GeneralTaskListPresenter(self, CoreDataGeneralTaskRepository.shared)
        
        configureNavigationItem()
        configureTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor("f2f2f7")
            navigationBar.shadowImage = UIImage()
            navigationBar.backgroundColor = UIColor("f2f2f7")
        }
        
        presenter?.updateTasks()
        generalTaskTableView.reloadData()
    }
    
    private func configureNavigationItem() {
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSpecificTaskTapped))
        addButton.tintColor = .red
        
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterSpecificTaskTapped))
        filterButton.tintColor = .red
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.text = "Общие задачи"
        
        calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonTapped))
        calendarButton.tintColor = .red
        
        navigationItem.rightBarButtonItems = [addButton, calendarButton, filterButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        titleLabel.setWidth(190)
    }
    
    
    private func configureTableView() {
        generalTaskTableView = UITableView(frame: .zero)
        generalTaskTableView.backgroundColor = .clear
        generalTaskTableView.delegate = self
        generalTaskTableView.dataSource = self
        generalTaskTableView.separatorStyle = .none
        generalTaskTableView.register(GeneralTaskTableViewCell.self, forCellReuseIdentifier: GeneralTaskTableViewCell.reuseIdentifier)
        generalTaskTableView.allowsSelection = true
        generalTaskTableView.allowsMultipleSelection = false
        generalTaskTableView.showsVerticalScrollIndicator = false
        
        view.addSubview(generalTaskTableView)
        generalTaskTableView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        generalTaskTableView.pinHorizontal(to: view, 8)
        generalTaskTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    @objc private func addSpecificTaskTapped() {
        let addGeneralTaskViewController = AddGeneralTaskViewController()
        addGeneralTaskViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addGeneralTaskViewController, animated: true)
    }
    
    @objc private func filterSpecificTaskTapped() {
        // TODO: -
    }
    
    @objc private func calendarButtonTapped() {
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.modalPresentationStyle = .custom
        datePickerViewController.transitioningDelegate = self
        datePickerViewController.goToDateAction = {[weak self] date in
            self?.presenter?.setStartDate(date: date)
            self?.generalTaskTableView.reloadData()
        }
        datePickerViewController.currentDate = presenter?.startDate ?? Date()
        present(datePickerViewController, animated: true)
    }
}


// MARK: - UITableViewDataSource
extension GeneralTaskListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = presenter?.getTaskCountByDate(dateIndex: section) ?? 0
        smallCells[section] = Array(repeating: false, count: count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GeneralTaskTableViewCell.reuseIdentifier, for: indexPath)
        guard let generalTaskCell = cell as? GeneralTaskTableViewCell else { return cell }
        guard let task = presenter?.getTaskByDate(dateIndex: indexPath.section, taskIndex: indexPath.row) else { return cell }
        generalTaskCell.configure(task: task, taskSelectAction: { [weak self] in self?.taskSelected(indexPath: indexPath) })
        smallCells[indexPath.section][indexPath.row] = generalTaskCell.isSmall
        return generalTaskCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = presenter?.getDatesCount() ?? 0
        smallCells = Array(repeating: [], count: count)
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return smallCells[indexPath.section][indexPath.row] ? 150 : 170
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = GeneralTabelViewHeader()
        header.configure(with: presenter?.getDateTitle(dateIndex: section) ?? "", tappedAction: { [weak self] in self?.toggleSection(index: section) })
        header.backgroundColor = UIColor("f2f2f7")
        if (presenter?.getTaskCountByDate(dateIndex: section) ?? 0 > 0) {
            header.toggleHeader()
        }
        return header
    }
    
    private func taskSelected(indexPath: IndexPath) {
        presenter?.toggleTaskComplete(dateIndex: indexPath.section, taskIndex: indexPath.row)
    }
    
    private func toggleSection(index: Int) {
        presenter?.toggleDate(dateIndex: index)

        let currentRowCount = generalTaskTableView.numberOfRows(inSection: index)
        let newRowCount = presenter?.getTaskCountByDate(dateIndex: index) ?? 0
        let rowCountDifference = newRowCount - currentRowCount

        generalTaskTableView.beginUpdates()
        
        if rowCountDifference > 0 {
            let indexPathsToInsert = (currentRowCount..<(currentRowCount + rowCountDifference)).map {
                IndexPath(row: $0, section: index)
            }
            generalTaskTableView.insertRows(at: indexPathsToInsert, with: .fade)
        } else if rowCountDifference < 0 {
            let indexPathsToDelete = ((newRowCount..<currentRowCount)).map {
                IndexPath(row: $0, section: index)
            }
            generalTaskTableView.deleteRows(at: indexPathsToDelete, with: .fade)
        }

        generalTaskTableView.endUpdates()
    }

}

// MARK: - UITableViewDelegate
extension GeneralTaskListViewController: UITableViewDelegate {
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension GeneralTaskListViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        if (presented is DatePickerViewController) {
            presentationController.divider = 1.5
        }
        return presentationController
    }
}
