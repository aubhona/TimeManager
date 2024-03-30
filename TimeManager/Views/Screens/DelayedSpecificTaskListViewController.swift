//
//  DelayedSpecificTaskList.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import UIKit

internal final class DelayedSpecificTaskListViewController: UIViewController {
    private var tasksCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var addButton: UIBarButtonItem = UIBarButtonItem()
    private var filterButton: UIBarButtonItem = UIBarButtonItem()
    private var titleLabel: UILabel = UILabel()
    private var presenter: DelayedSpecificTaskListPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor("f2f2f7")
        presenter = DelayedSpecificTaskListPresenter(self, CoreDataSpecificTaskRepository.shared)
        
        configureNavigationItem()
        configureTasksView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tasksCollectionView.performBatchUpdates({
            tasksCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    
    
    private func configureNavigationItem() {
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSpecificTaskTapped))
        addButton.tintColor = .red
        
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterSpecificTaskTapped))
        filterButton.tintColor = .red
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.text = "Отложенные задачи"
        titleLabel.sizeToFit()
        
        navigationItem.rightBarButtonItems = [addButton, filterButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func configureTasksView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 16, height: 90)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        tasksCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tasksCollectionView.backgroundColor = .clear
        tasksCollectionView.dataSource = self
        tasksCollectionView.delegate = self
        tasksCollectionView.register(DelayedSpecificTaskCollectionViewCell.self, forCellWithReuseIdentifier: DelayedSpecificTaskCollectionViewCell.reuseIdentifier)
        
        view.addSubview(tasksCollectionView)
        tasksCollectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        tasksCollectionView.pinHorizontal(to: view, 8)
        tasksCollectionView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        
        tasksCollectionView.allowsSelection = true
        tasksCollectionView.allowsMultipleSelection = false
        tasksCollectionView.showsVerticalScrollIndicator = false
    }
    
    @objc private func addSpecificTaskTapped() {
        let addSpecificTaskViewController = AddSpecificTaskViewController()
        addSpecificTaskViewController.hidesBottomBarWhenPushed = true
        addSpecificTaskViewController.isDelayedButtonTapped()
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
    
    @objc private func filterSpecificTaskTapped() {
        guard let presenter = presenter else { return }
        let tagFilterViewController = TagFilterViewController(nibName: nil, bundle: nil, presenter: presenter, tagRepository: CoreDataTagRepository.shared)
        tagFilterViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tagFilterViewController, animated: true)
    }
    
    private func taskSelected(index: Int) {
        presenter?.toggleTaskComplete(index: index)
    }
}

extension DelayedSpecificTaskListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.getTasksCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DelayedSpecificTaskCollectionViewCell.reuseIdentifier, for: indexPath)
        guard let taskCell = cell as? DelayedSpecificTaskCollectionViewCell else { return cell }
        guard let presenter = presenter else { return taskCell }
        let task = presenter.getTask(index: indexPath.row)
        taskCell.configure(task: task, taskSelectAction: { [weak self] in self?.taskSelected(index: indexPath.row) })
        
        return taskCell
    }
}

extension DelayedSpecificTaskListViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let specificTaskDescriptionView = SpecificTaskDescriptionViewController(task: presenter!.getTask(index: indexPath.row), deleteButtonTapped: deleteTaskAction, editButtonTapped: editTaskAction)
        specificTaskDescriptionView.modalPresentationStyle = .custom
        specificTaskDescriptionView.transitioningDelegate = self
        
        present(specificTaskDescriptionView, animated: true)
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
        addSpecificTaskViewController.isDelayedButtonTapped()
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
}


// MARK: - UIViewControllerTransitioningDelegate
extension DelayedSpecificTaskListViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}
