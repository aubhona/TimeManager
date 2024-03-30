//
//  AddSpecificTaskViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import UIKit

internal final class AddSpecificTaskViewController: UIViewController {
    private var titleLabel: UILabel = UILabel()
    private var nameLabel: UILabel = UILabel()
    private var nameTextField: UITextField = UITextField()
    private var descriptionLabel: UILabel = UILabel()
    private var descriptionTextView: UITextView = UITextView()
    private var dateTimePickerLabel: UILabel = UILabel()
    private var scheduledDatePicker = UIDatePicker()
    private var durationLabel: UILabel = UILabel()
    private var durationHourTextField: UITextField = UITextField()
    private var durationHourLabel: UILabel = UILabel()
    private var durationMinuteLabel: UILabel = UILabel()
    private var durationMinuteTextField: UITextField = UITextField()
    private var saveButton: UIButton = UIButton(type: .system)
    private var addReminderButton: UIButton = UIButton()
    private var addCalendarButton: UIButton = UIButton()
    private var tagsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tagLabel: UILabel = UILabel()
    private var addTagButton: UIButton = UIButton(type: .system)
    private var generalTaskLabel: UILabel = UILabel()
    private var generalTaskTextField: UITextField = UITextField()
    private var editTask: SpecificTaskDto?
    private var generalTask: GeneralTaskDto?
    private var selectedTagsCells: Set<IndexPath> = []
    private var isDelayedButton: UIButton = UIButton(type: .custom)
    private var dateStackView = UIStackView()
    private var generalStackView = UIStackView()
    
    private var presenter: AddSpecificTaskPresenter?
    
    init(task: SpecificTaskDto? = nil, _ selectedDate: Date = Date()) {
        editTask = task
        generalTask = task?.generalTask
        scheduledDatePicker.date = selectedDate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter = AddSpecificTaskPresenter(self, CoreDataSpecificTaskRepository.shared, CoreDataGeneralTaskRepository.shared,ReminderManager(), CalendarManager(), CoreDataTagRepository.shared)
        configureNavigationItem()
        configureViews()
        configureTaskEdit()
    }
    
    private func configureNavigationItem() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        backButton.tintColor = .red
        titleLabel.text = "Конкретная задача"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.navigationItem.leftBarButtonItem = backButton
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
        var paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Введите текст",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        view.addSubview(dateTimePickerLabel)
        dateTimePickerLabel.pinTop(to: nameTextField.bottomAnchor, 10)
        dateTimePickerLabel.pinLeft(to: view, 30)
        dateTimePickerLabel.text = "Время и дата"
        dateTimePickerLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dateTimePickerLabel.sizeToFit()
        
        view.addSubview(isDelayedButton)
        isDelayedButton.pinLeft(to: dateTimePickerLabel.trailingAnchor, 5)
        isDelayedButton.pinCenterY(to: dateTimePickerLabel)
        isDelayedButton.setTitle("Отложить задачу", for: .normal)
        isDelayedButton.setTitle("Установить дату", for: .selected)
        isDelayedButton.setTitleColor(.red, for: .normal)
        isDelayedButton.backgroundColor = .white
        isDelayedButton.addTarget(self, action: #selector(isDelayedButtonTapped), for: .touchUpInside)
        
        view.addSubview(dateStackView)
        dateStackView.pinLeft(to: view, 30)
        dateStackView.pinRight(to: view)
        dateStackView.pinTop(to: dateTimePickerLabel.bottomAnchor, 10)
        dateStackView.axis = .vertical
        dateStackView.alignment = .leading
        dateStackView.spacing = 10
        
        dateStackView.addArrangedSubview(scheduledDatePicker)
        scheduledDatePicker.locale = Locale(identifier: "ru")
        scheduledDatePicker.tintColor = .red
        
        addCalendarButton.setImage(UIImage(systemName: "square"), for: .normal)
        addCalendarButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addCalendarButton.setTitle(" Добавить в Календарь", for: .normal)
        addCalendarButton.setTitleColor(.red, for: .normal)
        dateStackView.addArrangedSubview(addCalendarButton)
        addCalendarButton.tintColor = .red
        addCalendarButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addCalendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        addReminderButton.setImage(UIImage(systemName: "square"), for: .normal)
        addReminderButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addReminderButton.setTitle(" Добавить в Напоминания", for: .normal)
        addReminderButton.setTitleColor(.red, for: .normal)
        dateStackView.addArrangedSubview(addReminderButton)
        addReminderButton.tintColor = .red
        addReminderButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addReminderButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        view.addSubview(durationLabel)
        durationLabel.pinTop(to: dateStackView.bottomAnchor, 10)
        durationLabel.pinLeft(to: view, 30)
        durationLabel.text = "Продолжительность:"
        durationLabel.font = UIFont.boldSystemFont(ofSize: 17)
        durationLabel.sizeToFit()
        
        view.addSubview(durationHourTextField)
        view.addSubview(durationMinuteTextField)
        view.addSubview(durationHourLabel)
        view.addSubview(durationMinuteLabel)
        durationHourTextField.pinLeft(to: durationLabel.trailingAnchor, 10)
        durationHourTextField.pinCenterY(to: durationLabel)
        durationHourTextField.attributedPlaceholder = NSAttributedString(string: "00",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        durationHourTextField.backgroundColor = UIColor("f2f2f7")
        durationHourTextField.layer.cornerRadius = 5
        durationHourTextField.setHeight(30)
        durationHourTextField.setWidth(30)
        durationHourTextField.contentVerticalAlignment = .center
        durationHourTextField.contentHorizontalAlignment = .center
        durationHourTextField.textAlignment = .center
        durationHourTextField.keyboardType = .numberPad
        durationHourTextField.tintColor = .red
        durationHourTextField.delegate = self
        
        durationHourLabel.pinLeft(to: durationHourTextField.trailingAnchor, 3)
        durationHourLabel.pinVertical(to: durationHourTextField)
        durationHourLabel.text = "ч"
        durationHourLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        durationMinuteTextField.pinLeft(to: durationHourLabel.trailingAnchor, 5)
        durationMinuteTextField.pinVertical(to: durationHourLabel)
        durationMinuteTextField.setHeight(30)
        durationMinuteTextField.setWidth(30)
        durationMinuteTextField.contentVerticalAlignment = .center
        durationMinuteTextField.contentHorizontalAlignment = .center
        durationMinuteTextField.textAlignment = .center
        durationMinuteTextField.keyboardType = .numberPad
        durationMinuteTextField.attributedPlaceholder = NSAttributedString(string: "00",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        durationMinuteTextField.backgroundColor = UIColor("f2f2f7")
        durationMinuteTextField.layer.cornerRadius = 5
        durationMinuteTextField.tintColor = .red
        durationMinuteTextField.delegate = self
        
        durationMinuteLabel.pinLeft(to: durationMinuteTextField.trailingAnchor, 3)
        durationMinuteLabel.pinVertical(to: durationMinuteTextField)
        durationMinuteLabel.text = "мин"
        durationMinuteLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.setWidth(view.bounds.width)
        descriptionLabel.pinTop(to: durationLabel.bottomAnchor, 10)
        descriptionLabel.pinLeft(to: view, 30)
        descriptionLabel.text = "Описание"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(descriptionTextView)
        descriptionTextView.pinHorizontal(to: view, 30)
        descriptionTextView.setHeight(90)
        descriptionTextView.pinTop(to: descriptionLabel.bottomAnchor, 10)
        descriptionTextView.backgroundColor = UIColor("f2f2f7")
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.tintColor = .red
        descriptionTextView.delegate = self
        descriptionTextView.text = "Введите описание"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = nameTextField.font
        
        view.addSubview(saveButton)
        saveButton.pinHorizontal(to: view, 70)
        saveButton.setHeight(35)
        saveButton.layer.cornerRadius = 15
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .red
        saveButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        view.addSubview(generalStackView)
        generalStackView.pinLeft(to: view, 30)
        generalStackView.pinRight(to: view)
        generalStackView.pinTop(to: descriptionTextView.bottomAnchor, 10)
        generalStackView.axis = .vertical
        generalStackView.alignment = .leading
        generalStackView.spacing = 10
        
        generalStackView.addArrangedSubview(generalTaskLabel)
        generalTaskLabel.text = "Общая задача"
        generalTaskLabel.font = UIFont.boldSystemFont(ofSize: 17)
        generalTaskLabel.sizeToFit()
        
        generalStackView.addArrangedSubview(generalTaskTextField)
        generalTaskTextField.setHeight(40)
        generalTaskTextField.setWidth(view.bounds.width - CGFloat(60))
        generalTaskTextField.backgroundColor = UIColor("f2f2f7")
        generalTaskTextField.layer.cornerRadius = 12
        generalTaskTextField.tintColor = .red
        paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: generalTaskTextField.frame.height))
        generalTaskTextField.leftView = paddingView
        generalTaskTextField.delegate = self
        generalTaskTextField.leftViewMode = .always
        generalTaskTextField.attributedPlaceholder = NSAttributedString(string: "Укажите общую задачу",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        view.addSubview(tagLabel)
        tagLabel.pinTop(to: generalStackView.bottomAnchor, 10)
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
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 21)
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
        presenter?.fillInputFileds(task: task, generalTaskDto: generalTask)
    }
    
    @objc public func isDelayedButtonTapped() {
        isDelayedButton.isSelected = !isDelayedButton.isSelected
        let newTitle = isDelayedButton.isSelected ? "Отложенная задача" : "Конкретная задача"
        UIView.animate(withDuration: 0.3) {
            self.scheduledDatePicker.isHidden = self.isDelayedButton.isSelected
            self.addCalendarButton.isHidden = self.isDelayedButton.isSelected
            self.addReminderButton.isHidden = self.isDelayedButton.isSelected
            self.generalTaskLabel.isHidden = self.isDelayedButton.isSelected
            self.generalTaskTextField.isHidden = self.isDelayedButton.isSelected
            self.view.layoutIfNeeded()
        }
        UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.titleLabel.text = newTitle
            self.titleLabel.sizeToFit()
        }, completion: nil)
    }
    
    public func setInputFields(name: String, description: String, date: Date, hourDuration: String, minuteDuration: String, generalTask: GeneralTaskDto?, selectedTagsIndexes: [Int]) {
        nameTextField.text = name
        scheduledDatePicker.date = date
        durationHourTextField.text = hourDuration
        durationMinuteTextField.text = minuteDuration
        descriptionTextView.text = description
        descriptionTextView.textColor = .black
        self.generalTask = generalTask
        if let generalTaskName = generalTask?.name {
            generalTaskTextField.text = generalTaskName
        }
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
        guard let name = nameTextField.text, !name.isEmpty,
              let taskDescription = descriptionTextView.text, taskDescription != "Введите описание",
              let durationHoursText = durationHourTextField.text, let durationHours = Int64(durationHoursText),
              let durationMinutesText = durationMinuteTextField.text, let durationMinutes = Int64(durationMinutesText) else {
            showAlert(title: "Ошибка ввода", message: "Заполните все поля")
            return
        }
        let totalDuration = (durationHours * 60) + durationMinutes
        do {
            try presenter?.addTask(
                name: name,
                description: taskDescription,
                scheduledDate: isDelayedButton.isSelected ? nil : scheduledDatePicker.date,
                duration: totalDuration,
                addToReminder: isDelayedButton.isSelected ? nil : addReminderButton.isSelected,
                addToCalendar: isDelayedButton.isSelected ? nil : addCalendarButton.isSelected,
                generalTaskId: isDelayedButton.isSelected ? nil : generalTask?.id,
                tagsIndexes: getSelectedCellsIndex()
            )
        } catch let error as NSError  {
            showAlert(title: "Ошибка сохранения", message: error.localizedDescription)
        }
        customBackTapped()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getSelectedCellsIndex() -> [Int] {
        return selectedTagsCells.map { $0.row }
    }
    
}

extension AddSpecificTaskViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == generalTaskTextField) {
            let generalTaskSearchViewController = GeneralTaskSearchViewController()
            generalTaskSearchViewController.actionBeforeClose = {[weak self] generalTask in
                self?.generalTask = generalTask
                self?.generalTaskTextField.text = generalTask.name
            }
            present(generalTaskSearchViewController, animated: true)
            return false
        }
        return true
    }
}

extension AddSpecificTaskViewController: UITextViewDelegate {
    
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
extension AddSpecificTaskViewController: UICollectionViewDelegate {
    
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
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
                cell.isTapped = false
                self.selectedTagsCells.remove(indexPath)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AddSpecificTaskViewController: UICollectionViewDataSource {
    
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
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
            tagViewCell.isTapped = false
        }
        return tagViewCell
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AddSpecificTaskViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        if (presented is GeneralTaskSearchViewController) {
            presentationController.divider = 1
        }
        return presentationController
    }
}
