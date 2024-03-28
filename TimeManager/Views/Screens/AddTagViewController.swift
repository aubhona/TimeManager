//
//  AddTagViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 27.03.2024.
//

import UIKit

internal final class AddTagViewController: UIViewController {
    private var presenter: AddTagPresenter?
    private var titleLabel: UILabel = UILabel()
    private var nameLabel: UILabel = UILabel()
    private var colorLabel: UILabel = UILabel()
    private var colorIndicatorView: UIView = UIView()
    private var nameTextField: UITextField = UITextField()
    private var saveButton: UIButton = UIButton(type: .system)
    private var swipeIndicatorView: UIView = UIView()
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var initialPosition: CGFloat = 0
    public var didFinishAddingTag: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = AddTagPresenter(view: self, tagRepository: CoreDataTagRepository.shared)
        configureSwipeIndicator()
        configurePanGestureRecognizer()
        configureViews()
    }
    
    private func configurePanGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func configureSwipeIndicator() {
        swipeIndicatorView = UIView(frame: CGRect(x: (self.view.frame.width / 2) - 50, y: 5, width: 100, height: 5))
        swipeIndicatorView.backgroundColor = UIColor.systemGray3
        swipeIndicatorView.layer.cornerRadius = 2.5
        self.view.addSubview(swipeIndicatorView)
    }
    
    private func configureViews() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.setWidth(view.bounds.width)
        titleLabel.pinTop(to: swipeIndicatorView, 10)
        titleLabel.pinLeft(to: view, 30)
        titleLabel.text = "Тег"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        view.addSubview(nameLabel)
        nameLabel.setWidth(view.bounds.width)
        nameLabel.pinTop(to: titleLabel.bottomAnchor, 10)
        nameLabel.pinLeft(to: view, 30)
        nameLabel.text = "Название"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(nameTextField)
        nameTextField.pinHorizontal(to: view, 30)
        nameTextField.setHeight(40)
        nameTextField.pinTop(to: nameLabel.bottomAnchor, 10)
        nameTextField.backgroundColor = UIColor("f2f2f7")
        nameTextField.layer.cornerRadius = 12
        nameTextField.tintColor = .red
        nameTextField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Введите текст",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
        view.addSubview(colorLabel)
        colorLabel.setWidth(view.bounds.width)
        colorLabel.pinTop(to: nameTextField.bottomAnchor, 10)
        colorLabel.pinLeft(to: view, 30)
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(colorIndicatorView)
        colorIndicatorView.setWidth(30)
        colorIndicatorView.setHeight(30)
        colorIndicatorView.layer.cornerRadius = 10
        colorIndicatorView.layer.borderColor = UIColor.black.cgColor
        colorIndicatorView.layer.borderWidth = 1.0
        colorIndicatorView.pinLeft(to: view, 30)
        colorIndicatorView.pinTop(to: colorLabel.bottomAnchor, 10)
        colorIndicatorView.backgroundColor = .systemPink
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentColorPicker))
        colorIndicatorView.addGestureRecognizer(tapGesture)
        colorIndicatorView.isUserInteractionEnabled = true
        
        view.addSubview(saveButton)
        saveButton.pinHorizontal(to: view, 70)
        saveButton.setHeight(35)
        saveButton.layer.cornerRadius = 15
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .red
        saveButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty
        else {
            showAlert(title: "Ошибка ввода", message: "Заполните все поля")
            return
        }
        do {
            try presenter?.addTag(name: name, color: colorIndicatorView.backgroundColor?.hexString ?? "000000")
        }
        catch let error as NSError  {
            showAlert(title: "Ошибка сохранения", message: error.localizedDescription)
        }
        didFinishAddingTag?()
        self.dismiss(animated: true)
    }
    
    @objc func presentColorPicker() {
        let colorPickerViewController = UIColorPickerViewController()
        colorPickerViewController.delegate = self
        colorPickerViewController.selectedColor = colorIndicatorView.backgroundColor ?? .systemPink
        present(colorPickerViewController, animated: true)
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

extension AddTagViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorIndicatorView.backgroundColor = viewController.selectedColor
        viewController.dismiss(animated: true)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorIndicatorView.backgroundColor = viewController.selectedColor
    }
}

extension AddTagViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
