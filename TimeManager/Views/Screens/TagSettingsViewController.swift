//
//  TagSettingsViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import UIKit

internal final class TagSettingsViewController: UIViewController {
    private var titleLabel: UILabel = UILabel()
    private var addButton: UIBarButtonItem = UIBarButtonItem()
    private var tagsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var saveButton: UIButton = UIButton(type: .system)
    private var selectedTagsCells: Set<IndexPath> = []
    private var presenter: TagSettingsPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationItem()
        configureSaveButton()
        configureTagCollectionView()
        presenter = TagSettingsPresenter(self, CoreDataTagRepository.shared)
    }
    
    private func configureNavigationItem() {
        titleLabel.text = "Теги"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTagButtonTapped))
        addButton.tintColor = .red
        
        self.navigationItem.titleView = titleLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func customBackTapped() {
        _ = navigationController?.popViewController(animated: true)
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
    
    private func configureSaveButton() {
        view.addSubview(saveButton)
        saveButton.pinHorizontal(to: view, 50)
        saveButton.setHeight(35)
        saveButton.layer.cornerRadius = 15
        saveButton.setTitle("Удалить выбранные теги", for: .normal)
        saveButton.backgroundColor = .red
        saveButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        presenter?.deleteSelectedTag(tagsIndexes: selectedTagsCells.map { $0.row })
        customBackTapped()
    }
    
    private func configureTagCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.bounds.width - 60.5, height: 40)
        layout.minimumLineSpacing = 5
        tagsCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        tagsCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reuseIdentifier)
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        view.addSubview(tagsCollectionView)
        tagsCollectionView.pinHorizontal(to: view, 30)
        tagsCollectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        tagsCollectionView.pinBottom(to: saveButton.topAnchor, 10)
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.showsHorizontalScrollIndicator = false
        tagsCollectionView.isPrefetchingEnabled = false
    }
}

// MARK: - UICollectionViewDelegate
extension TagSettingsViewController: UICollectionViewDelegate {
    
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
extension TagSettingsViewController: UICollectionViewDataSource {
    
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
extension TagSettingsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}
