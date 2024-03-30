//
//  SpecificTaskDescriptionView.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//

import UIKit

internal final class SpecificTaskDescriptionViewController: UIViewController {
    
    private var initialPosition: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var swipeIndicatorView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    private var descriptionImage: UIImageView = UIImageView()
    private var timeLabel: UILabel = UILabel()
    private var timeImage: UIImageView = UIImageView()
    private var task: SpecificTaskDto
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
    
    public var deleteButtonTappedAction: ((SpecificTaskDto) -> Void)?
    public var editButtonTappedAction: ((SpecificTaskDto) -> Void)?
    public var actionBeforeClose: (() -> Void)?
    
    init(task: SpecificTaskDto, deleteButtonTapped: ((SpecificTaskDto) -> Void)? = nil, editButtonTapped: ((SpecificTaskDto) -> Void)? = nil) {
        self.task = task
        self.deleteButtonTappedAction = deleteButtonTapped
        self.editButtonTappedAction = editButtonTapped
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        
        configureSwipeIndicator()
        configurePanGestureRecognizer()
        configureViews()
    }
    
    private func configureViews() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(titleLabel)
        titleLabel.pinTop(to: swipeIndicatorView, 10)
        titleLabel.pinCenterX(to: view)
        titleLabel.text = task.name
        titleLabel.sizeToFit()
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.pinHorizontal(to: view)
        scrollView.pinBottom(to: view)
        scrollView.pinTop(to: titleLabel.bottomAnchor, 5)
        
        scrollView.isScrollEnabled = true
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.pin(to: scrollView)
        contentView.setWidth(view.frame.width)
        
        descriptionImage = UIImageView(image: UIImage(systemName: "text.quote"))
        contentView.addSubview(descriptionImage)
        descriptionImage.pinLeft(to: contentView, 20)
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
        timeLabel.text = task.scheduledDate
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
        tagsStackView.setHeight(Double(task.tags.count) * 20.0)
        for tag in task.tags {
            let tagView = TagView()
            tagView.configure(with: tag.name, color: UIColor(tag.color))
            tagsStackView.addArrangedSubview(tagView)
        }
        if (task.tags.count == 0){
            tagImage.isHidden = true
        }
        
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
        contentView.addSubview(actionStackView)
        actionStackView.axis = .horizontal
        actionStackView.distribution = .equalSpacing
        actionStackView.spacing = view.bounds.width / 4
        
        actionStackView.pinCenterX(to: contentView)
        actionStackView.pinTop(to: tagsStackView.bottomAnchor, 20)
        actionStackView.pinBottom(to: contentView.bottomAnchor, 20)
        
        scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        handleTouchDown(sender)
        handleTouchUpInside(sender)
        deleteButtonTappedAction?(task)
        actionBeforeClose?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped(_ sender: UIButton) {
        handleTouchDown(sender)
        handleTouchUpInside(sender)
        editButtonTappedAction?(task)
        self.dismiss(animated: true, completion: nil)
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
    
    private func configureSwipeIndicator() {
        swipeIndicatorView = UIView(frame: CGRect(x: (self.view.frame.width / 2) - 50, y: 5, width: 100, height: 5))
        swipeIndicatorView.backgroundColor = UIColor.systemGray3
        swipeIndicatorView.layer.cornerRadius = 2.5
        self.view.addSubview(swipeIndicatorView)
    }
    
    private func configurePanGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handleDismissGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view?.superview)
        
        switch gesture.state {
        case .began:
            initialPosition = view.frame.origin.y
        case .changed:
            let newPosition = initialPosition + translation.y
            if newPosition > initialPosition {
                view.frame.origin.y = newPosition
            }
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: gesture.view).y
            if translation.y > view.bounds.height / 4 || velocity > 1500 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.view.frame.origin.y = self.initialPosition
                }
            }
        default:
            break
        }
    }
}
