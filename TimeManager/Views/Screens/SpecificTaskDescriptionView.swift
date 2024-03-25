//
//  SpecificTaskDescriptionView.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//

import UIKit

final class SpecificTaskDescriptionView: UIViewController {
    
    private var initialPosition: CGFloat = 0
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var swipeIndicatorView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var descriptionTextField: UITextField = UITextField()
    private var descriptionImage: UIImageView = UIImageView()
    private var timeLabel: UILabel = UILabel()
    private var timeImage: UIImageView = UIImageView()
    private var task: SpecificTaskDto
    private var deleteButton: UIButton = UIButton()
    private var editButton: UIButton = UIButton()
    private var actionStackView: UIStackView = UIStackView()
    
    
    init(task: SpecificTaskDto) {
        self.task = task
        
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
        titleLabel.pinTop(to: swipeIndicatorView, 20)
        titleLabel.pinLeft(to: view, 20)
        titleLabel.setWidth(view.bounds.width)
        
        descriptionImage = UIImageView(image: UIImage(systemName: "text.quote"))
        view.addSubview(descriptionImage)
        descriptionImage.pinLeft(to: titleLabel)
        descriptionImage.pinTop(to: titleLabel.bottomAnchor, 10)
        descriptionImage.tintColor = .red
        
        descriptionTextField = UITextField()
        view.addSubview(descriptionTextField)
        descriptionTextField.text = task.taskDescription
        descriptionTextField.pinLeft(to: descriptionImage.trailingAnchor, 5)
        descriptionTextField.pinTop(to: titleLabel.bottomAnchor, 10)
        
        timeImage = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        view.addSubview(timeImage)
        timeImage.tintColor = .red
        timeImage.pinTop(to: descriptionImage.bottomAnchor, 10)
        timeImage.pinLeft(to: descriptionImage)
        
        timeLabel = UILabel()
        timeLabel.text = task.scheduledDate
        view.addSubview(timeLabel)
        timeLabel.pinTop(to: descriptionImage.bottomAnchor, 10)
        timeLabel.pinLeft(to: descriptionTextField)
        timeLabel.setWidth(view.bounds.width)
        
        deleteButton = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: largeConfig), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.contentHorizontalAlignment = .center
        deleteButton.contentVerticalAlignment = .center
        
        editButton = UIButton(type: .system)
        editButton.setImage(UIImage(systemName: "pencil.line", withConfiguration: largeConfig), for: .normal)
        editButton.tintColor = .red
        
        view.addSubview(actionStackView)
        actionStackView.axis = .horizontal
        actionStackView.addArrangedSubview(deleteButton)
        actionStackView.addArrangedSubview(editButton)
        actionStackView.distribution = .equalSpacing
        actionStackView.spacing = view.bounds.width / 3
        
        actionStackView.pinCenterX(to: view)
        actionStackView.pinTop(to: timeLabel.bottomAnchor, 20)
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
