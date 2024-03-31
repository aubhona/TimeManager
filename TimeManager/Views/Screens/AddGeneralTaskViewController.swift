//
//  AddSpecificTaskViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import UIKit

internal final class AddGeneralTaskViewController: UIViewController {
    private var titleLabel: UILabel = UILabel()
    private var nameLabel: UILabel = UILabel()
    private var nameTextField: UITextField = UITextField()
    private var descriptionLabel: UILabel = UILabel()
    private var descriptionTextView: UITextView = UITextView()
    private var dateTimePickerLabel: UILabel = UILabel()
    private var deadlineDatePicker = UIDatePicker()
    private var saveButton: UIButton = UIButton(type: .system)
    private var addReminderButton: UIButton = UIButton()
    private var addCalendarButton: UIButton = UIButton()
    private var tagsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tagLabel: UILabel = UILabel()
    private var addTagButton: UIButton = UIButton(type: .system)
    private var editTask: GeneralTaskDto?
    private var selectedTagsCells: Set<IndexPath> = []
    
    private var presenter: AddGeneralTaskPresenter?
    
    init(task: GeneralTaskDto? = nil) {
        editTask = task
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationItem()
        presenter = AddGeneralTaskPresenter(self, CoreDataGeneralTaskRepository.shared, ReminderManager(), CalendarManager(), CoreDataTagRepository.shared)
        configureViews()
        configureTaskEdit()
    }
    
    private func configureNavigationItem() {
        titleLabel.text = "Общая задача"
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
    
    @objc private func customBackTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configureViews() {
        view.addSubview(nameLabel)
        nameLabel.setWidth(view.bounds.width)
        nameLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 5)
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
        
        view.addSubview(dateTimePickerLabel)
        dateTimePickerLabel.setWidth(view.bounds.width)
        dateTimePickerLabel.pinTop(to: nameTextField.bottomAnchor, 10)
        dateTimePickerLabel.pinLeft(to: view, 30)
        dateTimePickerLabel.text = "Время и дата"
        dateTimePickerLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        
        view.addSubview(deadlineDatePicker)
        deadlineDatePicker.pinTop(to: dateTimePickerLabel.bottomAnchor, 10)
        deadlineDatePicker.pinLeft(to: view, 30)
        deadlineDatePicker.locale = Locale(identifier: "ru")
        deadlineDatePicker.tintColor = .red
        
        addCalendarButton.setImage(UIImage(systemName: "square"), for: .normal)
        addCalendarButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addCalendarButton.setTitle(" Добавить в Календарь", for: .normal)
        addCalendarButton.setTitleColor(.red, for: .normal)
        view.addSubview(addCalendarButton)
        addCalendarButton.pinLeft(to: deadlineDatePicker)
        addCalendarButton.pinTop(to: deadlineDatePicker.bottomAnchor, 10)
        addCalendarButton.tintColor = .red
        addCalendarButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addCalendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        addReminderButton.setImage(UIImage(systemName: "square"), for: .normal)
        addReminderButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addReminderButton.setTitle(" Добавить в Напоминания", for: .normal)
        addReminderButton.setTitleColor(.red, for: .normal)
        view.addSubview(addReminderButton)
        addReminderButton.pinLeft(to: addCalendarButton)
        addReminderButton.pinTop(to: addCalendarButton.bottomAnchor, 5)
        addReminderButton.tintColor = .red
        addReminderButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addReminderButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.setWidth(view.bounds.width)
        descriptionLabel.pinTop(to: addReminderButton.bottomAnchor, 10)
        descriptionLabel.pinLeft(to: view, 30)
        descriptionLabel.text = "Описание"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(descriptionTextView)
        descriptionTextView.pinHorizontal(to: view, 30)
        descriptionTextView.setHeight(100)
        descriptionTextView.pinTop(to: descriptionLabel.bottomAnchor, 10)
        descriptionTextView.backgroundColor = UIColor("f2f2f7")
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.tintColor = .red
        descriptionTextView.delegate = self
        descriptionTextView.text = "Введите описание"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = nameTextField.font
        addDoneButtonOnKeyboard()
        
        view.addSubview(saveButton)
        saveButton.pinHorizontal(to: view, 70)
        saveButton.setHeight(35)
        saveButton.layer.cornerRadius = 15
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .red
        saveButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        view.addSubview(tagLabel)
        tagLabel.pinTop(to: descriptionTextView.bottomAnchor, 10)
        tagLabel.pinLeft(to: view, 30)
        tagLabel.text = "Теги"
        tagLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(addTagButton)
        let smallConfig = UIImage.SymbolConfiguration(scale: .medium)
        addTagButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: smallConfig), for: .normal)
        addTagButton.tintColor = .red
        addTagButton.pinLeft(to: tagLabel.trailingAnchor, 5)
        addTagButton.pinCenterY(to: tagLabel)
        addTagButton.addTarget(self, action: #selector(addTagButtonTapped), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.bounds.width - 60.5, height: 25)
        layout.minimumLineSpacing = 5
        tagsCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        tagsCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reuseIdentifier)
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        view.addSubview(tagsCollectionView)
        tagsCollectionView.pinHorizontal(to: view, 30)
        tagsCollectionView.pinTop(to: tagLabel.bottomAnchor, 10)
        tagsCollectionView.pinBottom(to: saveButton.topAnchor, 10)
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.showsHorizontalScrollIndicator = false
        tagsCollectionView.isPrefetchingEnabled = false
    }
    
    private func configureTaskEdit() {
        guard let task = editTask else { return }
        presenter?.fillInputFileds(task: task)
    }
    
    public func setInputFields(name: String, description: String, date: Date, selectedTagsIndexes: [Int]) {
        nameTextField.text = name
        deadlineDatePicker.date = date
        descriptionTextView.text = description
        descriptionTextView.textColor = .black
        selectCells(withIndexes: selectedTagsIndexes)
    }
    
    private func selectCells(withIndexes indexes: [Int]) {
        tagsCollectionView.allowsMultipleSelection = true
        indexes.forEach { index in
            let indexPath = IndexPath(row: index, section: 0)
            selectedTagsCells.insert(indexPath)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func addTagButtonTapped() {
        let addTagViewController = AddTagViewController()
        addTagViewController.modalPresentationStyle = .custom
        addTagViewController.transitioningDelegate = self
        addTagViewController.didFinishAddingTag = { [weak self] in
            self?.tagsCollectionView.reloadData()
        }
        present(addTagViewController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty, descriptionTextView.text != "Введите описание" else {
            showAlert(title: "Ошибка ввода", message: "Заполните все поля")
            return
        }
        do {
            try presenter?.addTask(
                name: name,
                description: descriptionTextView.text,
                deadlineDate: deadlineDatePicker.date,
                addToReminder: addReminderButton.isSelected,
                addToCalendar: addCalendarButton.isSelected,
                tagsIndexes: getSelectedCellsIndex()
            )
        } catch let error as NSError  {
            showAlert(title: "Ошибка сохранения", message: error.localizedDescription)
        }
        customBackTapped()
    }
    
    private func addDoneButtonOnKeyboard() {
        let customToolbar: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = customToolbar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        customToolbar.addSubview(blurEffectView)
        
        let toolbar: UIToolbar = UIToolbar(frame: blurEffectView.bounds)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(doneButtonAction))
        done.tintColor = .red
        
        toolbar.items = [flexSpace, done]
        
        customToolbar.addSubview(toolbar)
        
        descriptionTextView.inputAccessoryView = customToolbar
    }
    
    @objc private func doneButtonAction() {
        descriptionTextView.resignFirstResponder()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in }
        
        alert.view.tintColor = .red
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getSelectedCellsIndex() -> [Int] {
        return selectedTagsCells.map { $0.row }
    }
    
}

extension AddGeneralTaskViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddGeneralTaskViewController: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor != .lightGray {
            return
        }
        descriptionTextView.text = nil
        descriptionTextView.textColor = .black
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if !descriptionTextView.text.isEmpty {
            return
        }
        descriptionTextView.text = "Введите описание"
        descriptionTextView.textColor = .lightGray
    }
}

// MARK: - UICollectionViewDelegate
extension AddGeneralTaskViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell, cell.isTapped {
            self.collectionView(collectionView, didDeselectItemAt: indexPath)
            return
        }
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                cell.layer.borderColor = UIColor.red.cgColor
                cell.layer.borderWidth = 1
                cell.isTapped = true
                self.selectedTagsCells.insert(indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell, !cell.isTapped {
            self.collectionView(collectionView, didSelectItemAt: indexPath)
            return
        }
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
                cell.transform = CGAffineTransform.identity
                cell.layer.borderColor = UIColor.black.cgColor
                cell.layer.borderWidth = 1
                cell.isTapped = false
                self.selectedTagsCells.remove(indexPath)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AddGeneralTaskViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.getTagsCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reuseIdentifier, for: indexPath)
        guard let tagViewCell = cell as? TagCollectionViewCell else { return cell }
        guard let tagDto = presenter?.getTag(index: indexPath.row) else { return cell }
        tagViewCell.configureTag(name: tagDto.name, color: UIColor(tagDto.color))
        if selectedTagsCells.contains(indexPath) {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 1
            tagViewCell.isTapped = true
        } else {
            cell.transform = CGAffineTransform.identity
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            tagViewCell.isTapped = false
        }
        return tagViewCell
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AddGeneralTaskViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        if (presented is AddTagViewController) {
            presentationController.divider = 1.5
        }
        return presentationController
    }
}
