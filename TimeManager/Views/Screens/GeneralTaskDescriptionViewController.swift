//
//  GeneralTaskDescriptionViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import UIKit

internal final class GeneralTaskDescriptionViewController: UIViewController {
    
    private var titleLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    private var descriptionImage: UIImageView = UIImageView()
    private var timeLabel: UILabel = UILabel()
    private var timeImage: UIImageView = UIImageView()
    public var task: GeneralTaskDto
    private var deleteButton: UIButton = UIButton()
    private var editButton: UIButton = UIButton()
    private var actionStackView: UIStackView = UIStackView()
    private var scrollView: UIScrollView = UIScrollView()
    private var contentView = UIView()
    private var deleteButtonLabel: UILabel = UILabel()
    private var editButtonLabel: UILabel = UILabel()
    private var deleteButtonStackView: UIStackView = UIStackView()
    private var editButtonStackView: UIStackView = UIStackView()
    private var tagsStackView: UIStackView = UIStackView()
    private var tagImage: UIImageView = UIImageView()
    private var actionTooolBar: UIToolbar = UIToolbar()
    private var specificTaskCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var presenter: GeneralTaskDescriptionPresenter?
    private var specificTaskHeightConstraint: NSLayoutConstraint?
    private var tagsStackViewHeightConstaint: NSLayoutConstraint?
    
    public var deleteButtonTappedAction: ((GeneralTaskDto) -> Void)?
    public var editButtonTappedAction: ((GeneralTaskDto) -> Void)?
    
    init(task: GeneralTaskDto, deleteButtonTapped: ((GeneralTaskDto) -> Void)? = nil, editButtonTapped: ((GeneralTaskDto) -> Void)? = nil) {
        self.task = task
        self.deleteButtonTappedAction = deleteButtonTapped
        self.editButtonTappedAction = editButtonTapped
        super.init(nibName: nil, bundle: nil)
        presenter = GeneralTaskDescriptionPresenter(self, CoreDataGeneralTaskRepository.shared, CoreDataSpecificTaskRepository.shared, task)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureNavigationItem()
        configureActionToolBar()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.updateViewGeneralTask()
        specificTaskCollectionView.performBatchUpdates({
            specificTaskCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
        view.layoutIfNeeded()
    }
    
    private func configureNavigationItem() {
        titleLabel.text = task.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = .white
        }
    }
    
    private func configureActionToolBar() {
        deleteButton = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular, scale: .large)
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: largeConfig), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: [.touchUpInside, .touchUpOutside])
        
        editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "pencil.line", withConfiguration: largeConfig), for: .normal)
        editButton.tintColor = .red
        editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: [.touchUpInside, .touchUpOutside])
        
        deleteButtonLabel = UILabel()
        deleteButtonLabel.text = "Удалить"
        deleteButtonLabel.textColor = .red
        deleteButtonLabel.font = UIFont.systemFont(ofSize: 13)
        
        editButtonLabel = UILabel()
        editButtonLabel.text = "Редактировать"
        editButtonLabel.textColor = .red
        editButtonLabel.font = UIFont.systemFont(ofSize: 13)
        
        deleteButtonStackView = UIStackView(arrangedSubviews: [deleteButton, deleteButtonLabel])
        deleteButtonStackView.axis = .vertical
        deleteButtonStackView.alignment = .center
        deleteButtonStackView.spacing = 5
        
        editButtonStackView = UIStackView(arrangedSubviews: [editButton, editButtonLabel])
        editButtonStackView.axis = .vertical
        editButtonStackView.alignment = .center
        editButtonStackView.spacing = 5
        
        actionStackView = UIStackView(arrangedSubviews: [deleteButtonStackView, editButtonStackView])
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        
        actionTooolBar = UIToolbar()
        actionTooolBar.backgroundColor = .white
        actionTooolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        actionTooolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        actionTooolBar.setItems([
            UIBarButtonItem(customView: actionStackView)
        ], animated: false)
        view.addSubview(actionTooolBar)
        actionTooolBar.pinHorizontal(to: view)
        actionTooolBar.pinBottom(to: view)
        actionTooolBar.setHeight(80)
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        handleTouchDown(sender)
        handleTouchUpInside(sender)
        deleteButtonTappedAction?(task)
        customBackTapped()
    }
    
    @objc private func editButtonTapped(_ sender: UIButton) {
        handleTouchDown(sender)
        handleTouchUpInside(sender)
        editButtonTappedAction?(task)
    }
    
    @objc private func customBackTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configureViews() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.pinHorizontal(to: view)
        scrollView.pinBottom(to: actionTooolBar.topAnchor)
        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.pin(to: scrollView)
        contentView.setWidth(view.frame.width)
        
        scrollView.isScrollEnabled = true
        
        descriptionImage = UIImageView(image: UIImage(systemName: "text.quote"))
        contentView.addSubview(descriptionImage)
        descriptionImage.pinLeft(to: contentView, 30)
        descriptionImage.pinTop(to: contentView, 5)
        descriptionImage.tintColor = .red
        
        descriptionLabel = UILabel()
        contentView.addSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = task.taskDescription
        descriptionLabel.pinLeft(to: descriptionImage.trailingAnchor, 5)
        descriptionLabel.pinTop(to: descriptionImage)
        
        timeImage = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        contentView.addSubview(timeImage)
        timeImage.tintColor = .red
        timeImage.pinTop(to: descriptionLabel.bottomAnchor, 10)
        timeImage.pinLeft(to: descriptionImage)
        
        timeLabel = UILabel()
        timeLabel.text = task.deadlineDate
        contentView.addSubview(timeLabel)
        timeLabel.pinTop(to: descriptionLabel.bottomAnchor, 10)
        timeLabel.pinLeft(to: descriptionLabel)
        
        tagImage = UIImageView(image: UIImage(systemName: "tag"))
        tagImage.tintColor = .red
        contentView.addSubview(tagImage)
        tagImage.pinTop(to: timeImage.bottomAnchor, 10)
        tagImage.pinLeft(to: timeImage)
        
        tagsStackView = UIStackView()
        tagsStackView.clearsContextBeforeDrawing = true
        tagsStackView.axis = .vertical
        tagsStackView.clipsToBounds = true
        tagsStackView.distribution = .fillEqually
        contentView.addSubview(tagsStackView)
        tagsStackView.pinTop(to: tagImage)
        tagsStackView.pinLeft(to: tagImage.trailingAnchor, 5)
        tagsStackView.setWidth(view.bounds.width)
        tagsStackViewHeightConstaint = tagsStackView.setHeight(Double(task.tags.count) * 20.0)
        for tag in task.tags {
            let tagView = TagView()
            tagView.configure(with: tag.name, color: UIColor(tag.color))
            tagsStackView.addArrangedSubview(tagView)
        }
        tagImage.isHidden = task.tags.count == 0
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 30, height: 90)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        specificTaskCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        specificTaskCollectionView.backgroundColor = .clear
        specificTaskCollectionView.dataSource = self
        specificTaskCollectionView.delegate = self
        specificTaskCollectionView.register(DelayedSpecificTaskCollectionViewCell.self, forCellWithReuseIdentifier: DelayedSpecificTaskCollectionViewCell.reuseIdentifier)
        
        contentView.addSubview(specificTaskCollectionView)
        specificTaskCollectionView.pinTop(to: tagsStackView.bottomAnchor, 10)
        specificTaskCollectionView.pinHorizontal(to: contentView)
        specificTaskCollectionView.pinBottom(to: contentView)
        specificTaskHeightConstraint = specificTaskCollectionView.setHeight(0)
        
        specificTaskCollectionView.allowsSelection = true
        specificTaskCollectionView.allowsMultipleSelection = false
        specificTaskCollectionView.showsVerticalScrollIndicator = false
        
        scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }
    
    private func clearTagsStackView() {
        let arrangedSubviews = tagsStackView.arrangedSubviews
        for view in arrangedSubviews {
            tagsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    public func updateInputs() {
        titleLabel.text = task.name
        timeLabel.text = task.deadlineDate
        titleLabel.sizeToFit()
        timeLabel.sizeToFit()
        clearTagsStackView()
        tagsStackViewHeightConstaint?.constant = Double(task.tags.count) * 20.0
        for tag in task.tags {
            let tagView = TagView()
            tagView.configure(with: tag.name, color: UIColor(tag.color))
            tagsStackView.addArrangedSubview(tagView)
        }
        if (task.tags.count == 0){
            tagImage.isHidden = true
        }
    }
    
    @objc private func handleTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.35) {
            sender.alpha = 0.5
        }
    }
    
    
    @objc private func handleTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.35) {
            sender.alpha = 1.0
        }
    }
}

extension GeneralTaskDescriptionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = presenter?.getSpecificTasksCount() ?? 0
        specificTaskHeightConstraint?.constant = Double(count * 90 + (count - 1) * 10)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DelayedSpecificTaskCollectionViewCell.reuseIdentifier, for: indexPath)
        guard let taskCell = cell as? DelayedSpecificTaskCollectionViewCell else { return cell }
        guard let presenter = presenter else { return taskCell }
        let task = presenter.getSpecificTask(index: indexPath.row)
        taskCell.configure(task: task, taskSelectAction: { [weak self] in self?.taskSelected(index: indexPath.row) }, UIColor("f2f2f7"))
        
        return taskCell
    }
    
    private func taskSelected(index: Int) {
        presenter?.toggleTaskComplete(index: index)
    }
}

extension GeneralTaskDescriptionViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let specificTaskDescriptionView = SpecificTaskDescriptionViewController(task: presenter!.getSpecificTask(index: indexPath.row), deleteButtonTapped: deleteTaskAction(task:), editButtonTapped: editTaskAction(task:))
        specificTaskDescriptionView.modalPresentationStyle = .custom
        specificTaskDescriptionView.transitioningDelegate = self
        present(specificTaskDescriptionView, animated: true)
    }
    
    private func deleteTaskAction(task: SpecificTaskDto) {
        presenter?.deleteSpecificTask(taskId: task.id)
        specificTaskCollectionView.performBatchUpdates({
            specificTaskCollectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
        view.layoutIfNeeded()
    }
    
    private func editTaskAction(task: SpecificTaskDto) {
        let addSpecificTaskViewController = AddSpecificTaskViewController(task: task)
        addSpecificTaskViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSpecificTaskViewController, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension GeneralTaskDescriptionViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}

