//
//  ViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 12.03.2024.
//

import UIKit

internal final class SpecificTaskListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarDelegate {
    
    private var addButton: UIBarButtonItem = UIBarButtonItem()
    private var calendarButton: UIBarButtonItem = UIBarButtonItem()
    private var filterButton: UIBarButtonItem = UIBarButtonItem()
    private var dateLabel: UILabel = UILabel()
    private var weekCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tasksCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var scrollStartPoint: CGPoint?
    
    private var presenter: SpecificTaskListPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("f2f2f7")
        presenter = SpecificTaskListPresenter(self, CoreDataSpecificTaskRepository.shared, CoreDataTagRepository.shared, CoreDataGeneralTaskRepository.shared)
        
        configureNavigationItem()
        configureWeekView()
        configureTasksView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.checkTags()
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        weekCollectionView.scrollToItem(at: IndexPath(row: presenter?.currentWeekIndex ?? .zero, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    public func displayCurrentMonth(date: String) {
        UIView.transition(with: dateLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.dateLabel.text = date
        }, completion: nil)
    }
    
    private func configureNavigationItem() {
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSpecificTaskTapped))
        addButton.tintColor = .red
        
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterSpecificTaskTapped))
        filterButton.tintColor = .red
        
        calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonTapped))
        calendarButton.tintColor = .red
        
        presenter?.setCurrentMonth()
        dateLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        navigationItem.rightBarButtonItems = [addButton, calendarButton, filterButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dateLabel)
        dateLabel.setWidth(190)
    }
    
    private func configureWeekView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: (view.frame.height / 11))
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        layout.scrollDirection = .horizontal
        
        
        weekCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        
        weekCollectionView.collectionViewLayout = layout
        weekCollectionView.backgroundColor = .clear
        weekCollectionView.showsHorizontalScrollIndicator = false
        weekCollectionView.isPagingEnabled = true
        weekCollectionView.dataSource = self
        weekCollectionView.delegate = self
        weekCollectionView.allowsSelection = true
        weekCollectionView.allowsMultipleSelection = false
        
        weekCollectionView.register(WeekCollectionViewCell.self, forCellWithReuseIdentifier: WeekCollectionViewCell.reuseIdentifier)
        
        view.addSubview(weekCollectionView)
        weekCollectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        weekCollectionView.pinHorizontal(to: view)
        weekCollectionView.pinBottom(to: view.safeAreaLayoutGuide.topAnchor, -(layout.itemSize.height + 5))
    }
    
    
    
    // MARK: - Collection View Data Source
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.weekCollectionView {
            return presenter?.getWeeksCount() ?? .zero
        } else if collectionView == self.tasksCollectionView {
            return presenter?.getTasksCount() ?? .zero
        }
        
        return .zero
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.weekCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekCollectionViewCell.reuseIdentifier, for: indexPath)
            guard let weekCell = cell as? WeekCollectionViewCell else { return cell }
            
            weekCell.configure(
                dates: presenter?.getWeek(weekIndex: indexPath.row) ?? [(Int, String)](),
                index: presenter?.getSelectedWeekDay() ?? .zero,
                selectedDayChanged: selectedDayChanged
            )
            presenter?.setCurrentMonth()
            
            return weekCell
            
        } else if collectionView == self.tasksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpecificTaskCollectionViewCell.reuseIdentifier, for: indexPath)
            guard let taskCell = cell as? SpecificTaskCollectionViewCell else { return cell }
            
            guard let presenter = presenter else { return taskCell }
            let task = presenter.getTask(index: indexPath.row)
            taskCell.configure(task: task, taskSelectAction: { [weak self] in self?.taskSelected(index: indexPath.row) })
            
            return taskCell
        }
        
        return UICollectionViewCell()
    }
    
    public func selectedDayChanged(weekDay: Int) {
        presenter?.setSelectedDay(weekDay: weekDay)
        presenter?.setCurrentMonth()
        let sortedIndexPaths = weekCollectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row }
        var indexPathsToUpdate = [IndexPath]()
        for indexPath in sortedIndexPaths {
            indexPathsToUpdate.append(indexPath)
            if indexPath.row > 0 {
                let previousIndexPath = IndexPath(item: indexPath.row - 1, section: indexPath.section)
                indexPathsToUpdate.append(previousIndexPath)
            }
            
            let nextIndexPath = IndexPath(item: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row < weekCollectionView.numberOfItems(inSection: indexPath.section) {
                indexPathsToUpdate.append(nextIndexPath)
            }
        }
        let uniqueIndexPathsToUpdate = Array(Set(indexPathsToUpdate))
        weekCollectionView.reloadItems(at: uniqueIndexPathsToUpdate)
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    @objc private func addSpecificTaskTapped() {
        let addSpecificTaskViewController = AddSpecificTaskViewController(task: nil, presenter?.selectedDay ?? Date())
        addSpecificTaskViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
    
    @objc private func filterSpecificTaskTapped() {
        guard let presenter = presenter else { return }
        let tagFilterViewController = TagFilterViewController(nibName: nil, bundle: nil, presenter: presenter, tagRepository: CoreDataTagRepository.shared)
        tagFilterViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tagFilterViewController, animated: true)
    }
    
    @objc private func calendarButtonTapped() {
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.modalPresentationStyle = .custom
        datePickerViewController.transitioningDelegate = self
        datePickerViewController.goToDateAction = {[weak self] date in
            self?.presenter?.setSelectedDay(date: date)
        }
        datePickerViewController.currentDate = presenter?.selectedDay ?? Date()
        present(datePickerViewController, animated: true)
    }
    
    public func scrollToWeekIndex(weekIndex: Int) {
        weekCollectionView.scrollToItem(at: IndexPath(row: weekIndex, section: 0), at: .centeredHorizontally, animated: true)
        weekCollectionView.reloadData()
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    private func configureTasksView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 16, height: 100)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        tasksCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tasksCollectionView.backgroundColor = .clear
        tasksCollectionView.dataSource = self
        tasksCollectionView.delegate = self
        tasksCollectionView.register(SpecificTaskCollectionViewCell.self, forCellWithReuseIdentifier: SpecificTaskCollectionViewCell.reuseIdentifier)
        
        view.addSubview(tasksCollectionView)
        tasksCollectionView.pinTop(to: weekCollectionView.bottomAnchor, 10)
        tasksCollectionView.pinHorizontal(to: view, 8)
        tasksCollectionView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        
        tasksCollectionView.allowsSelection = true
        tasksCollectionView.allowsMultipleSelection = false
        tasksCollectionView.showsVerticalScrollIndicator = false
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == weekCollectionView) {
            return
        }
        let specificTaskDescriptionView = SpecificTaskDescriptionViewController(task: presenter!.getTask(index: indexPath.row), deleteButtonTapped: deleteTaskAction, editButtonTapped: editTaskAction)
        specificTaskDescriptionView.modalPresentationStyle = .custom
        specificTaskDescriptionView.transitioningDelegate = self
        
        present(specificTaskDescriptionView, animated: true)
    }
    
    private func taskSelected(index: Int) {
        presenter?.toggleTaskComplete(index: index)
    }
    
    private func deleteTaskAction(task: SpecificTaskDto) {
        presenter?.deleteTask(taskId: task.id)
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    private func editTaskAction(task: SpecificTaskDto) {
        let addSpecificTaskViewController = AddSpecificTaskViewController(task: task)
        addSpecificTaskViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
}


extension SpecificTaskListViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollStartPoint = scrollView.contentOffset
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == tasksCollectionView) {
            return
        }
        guard let startPoint = scrollStartPoint else { return }
        if (scrollView.contentOffset == startPoint) {
            return
        }
        presenter?.addWeekToSelectedDay(weekIndex: weekCollectionView.indexPathsForVisibleItems.max()?.row ?? .zero)
        presenter?.setCurrentMonth()
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SpecificTaskListViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        if (presented is DatePickerViewController) {
            presentationController.divider = 1.5
        }
        return presentationController
    }
}
