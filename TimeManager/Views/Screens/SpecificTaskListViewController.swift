//
//  ViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 12.03.2024.
//

import UIKit

final class SpecificTaskListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarDelegate {
    
    private var addButton: UIBarButtonItem = UIBarButtonItem()
    private var filterButton: UIBarButtonItem = UIBarButtonItem()
    private var dateLabel: UILabel = UILabel()
    private var weekCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tasksCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var lineView: UIView = UIView()
    
    private var presenter: SpecificTaskListPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("f2f2f7")
        presenter = SpecificTaskListPresenter(self, CoreDataSpecificTaskRepository.shared)
        
        configureNavigationItem()
        configureWeekView()
        configureTasksView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        weekCollectionView.scrollToItem(at: IndexPath(row: presenter?.getStartWeek() ?? .zero, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    public func displayCurrentMonth(date: String) {
        dateLabel.text = date
    }
    
    private func configureNavigationItem() {
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSpecificTaskTapped))
        addButton.tintColor = .red
        
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterSpecificTaskTapped))
        filterButton.tintColor = .red
        
        presenter?.setCurrentMonth()
        dateLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        navigationItem.rightBarButtonItems = [addButton, filterButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dateLabel)
        dateLabel.setWidth(200)
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
                index: presenter?.getSelectedDay() ?? .zero,
                selectedDayChanged: selectedDayChanged
            )
            presenter?.setCurrentMonth()
            
            return weekCell
            
        } else if collectionView == self.tasksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.reuseIdentifier, for: indexPath)
            guard let taskCell = cell as? TaskCollectionViewCell else { return cell }
            
            guard let presenter = presenter else { return taskCell }
            taskCell.configure(task: presenter.getTask(index: indexPath.row), taskSelectAction: { self.taskSelected(index: indexPath.row) })
            
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
        let addSpecificTaskViewController = AddSpecificTaskViewController()
        addSpecificTaskViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
    
    @objc private func filterSpecificTaskTapped() {
        // TODO: -
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
        tasksCollectionView.register(TaskCollectionViewCell.self, forCellWithReuseIdentifier: TaskCollectionViewCell.reuseIdentifier)
        
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
        let specificTaskDescriptionView = SpecificTaskDescriptionView(task: presenter!.getTask(index: indexPath.row))
        specificTaskDescriptionView.modalPresentationStyle = .custom
        specificTaskDescriptionView.transitioningDelegate = self
        
        present(specificTaskDescriptionView, animated: true)
    }
    
    private func taskSelected(index: Int) {
        presenter?.completeTask(index: index)
    }
}


extension SpecificTaskListViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == tasksCollectionView) {
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
        return presentationController
    }
}
