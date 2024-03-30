//
//  TagFilterViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import UIKit


internal final class TagFilterViewController: UIViewController {
    private var presenter: Presenter
    private var titleLabel: UILabel = UILabel()
    private var saveButton: UIButton = UIButton(type: .system)
    private var tagsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tagLabel: UILabel = UILabel()
    private var selectedTagsCells: Set<IndexPath> = []
    private var resetTagsButton: UIButton = UIButton(type: .custom)
    private var tags: [TagDto]
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: Presenter, tagRepository: TagRepository) {
        self.presenter = presenter
        tags = tagRepository.getAllTags().compactMap({ TagDto(id: $0.id!, name: $0.name!, color: $0.color!) })
        for i in 0..<presenter.tags.count {
            selectedTagsCells.insert(IndexPath(row: tags.firstIndex(where: { $0.id == presenter.tags[i].id })!, section: 0))
        }
        
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureNavigationItem()
        configureTagLabel()
        configureResetTagButton()
        configureSaveButton()
        configureTagsCollectionView()
    }
    
    private func configureResetTagButton() {
        view.addSubview(resetTagsButton)
        resetTagsButton.pinLeft(to: tagLabel.trailingAnchor, 5)
        resetTagsButton.pinCenterY(to: tagLabel)
        resetTagsButton.setTitle("Сбросить фильтр", for: .normal)
        resetTagsButton.setTitleColor(.red, for: .normal)
        resetTagsButton.backgroundColor = .white
        resetTagsButton.addTarget(self, action: #selector(resetTagsButtonTapped), for: .touchUpInside)
    }
    
    @objc private func resetTagsButtonTapped() {
        if (!selectedTagsCells.isEmpty) {
            selectedTagsCells.removeAll()
            tagsCollectionView.performBatchUpdates({
                tagsCollectionView.reloadSections([0])
            })
        } else {
            for i in 0..<presenter.tags.count {
                let indexPath = IndexPath(row: tags.firstIndex(where: { $0.id == presenter.tags[i].id })!, section: 0)
                selectedTagsCells.insert(indexPath)
                self.collectionView(tagsCollectionView, didSelectItemAt: indexPath)
            }
        }
    }
    
    private func configureNavigationItem() {
        titleLabel.text = "Фильтр"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
    }
    
    @objc private func customBackTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configureTagLabel() {
        view.addSubview(tagLabel)
        tagLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        tagLabel.pinLeft(to: view, 30)
        tagLabel.text = "Теги"
        tagLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    private func configureSaveButton() {
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
    
    @objc private func saveButtonTapped() {
        presenter.tags = selectedTagsCells.map { tags[$0.row] }
        customBackTapped()
    }
    
    private func configureTagsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width - 55, height: 35)
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
}

extension TagFilterViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reuseIdentifier, for: indexPath)
        guard let tagViewCell = cell as? TagCollectionViewCell else { return cell }
        let tagDto = tags[indexPath.row]
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

extension TagFilterViewController: UICollectionViewDelegate {
    
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
