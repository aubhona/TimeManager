//
//  SettingsViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 30.03.2024.
//

import UIKit
import SafariServices

internal final class SettingsViewController: UIViewController {
    private var titleLabel: UILabel = UILabel()
    private var tagSettingsButton: UIButton = UIButton(type: .system)
    private var clearDataButton: UIButton = UIButton(type: .system)
    private var termsOfServiceButton: UIButton = UIButton(type: .system)
    private var aboutUsButton: UIButton = UIButton(type: .system)
    private var presenter: SettingsPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor("f2f2f7")
        presenter = SettingsPresenter(self, CoreDataSpecificTaskRepository.shared, CoreDataTagRepository.shared, CoreDataGeneralTaskRepository.shared)
        
        configureNavigationItem()
        configureTagSettingsButton()
        configureTermsOfServiceButton()
        configureAboutUsButton()
        configureClearDataButton()
    }
    
    private func configureNavigationItem() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.text = "Настройки"
        titleLabel.sizeToFit()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func configureTagSettingsButton() {
        tagSettingsButton.setTitle("  Настроить теги", for: .normal)
        tagSettingsButton.backgroundColor = .white
        tagSettingsButton.layer.cornerRadius = 11
        tagSettingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        tagSettingsButton.setTitleColor(.black, for: .normal)
        tagSettingsButton.contentHorizontalAlignment = .left
        tagSettingsButton.setHeight(40)
        
        view.addSubview(tagSettingsButton)
        tagSettingsButton.pinHorizontal(to: view, 15)
        tagSettingsButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 10)
        
        tagSettingsButton.addTarget(self, action: #selector(tagSettingsButtonTapped), for: .touchUpInside)
    }
    
    private func configureClearDataButton() {
        clearDataButton.setTitle("Очистить все данные", for: .normal)
        clearDataButton.backgroundColor = .white
        clearDataButton.layer.cornerRadius = 11
        clearDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        clearDataButton.setTitleColor(.red, for: .normal)
        clearDataButton.setHeight(40)

        view.addSubview(clearDataButton)
        clearDataButton.pinHorizontal(to: aboutUsButton)
        clearDataButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        
        clearDataButton.addTarget(self, action: #selector(deleteAllDataButtonTapped), for: .touchUpInside)
    }
    
    private func configureTermsOfServiceButton() {
        termsOfServiceButton.setTitle("  Пользовательское соглашение", for: .normal)
        termsOfServiceButton.backgroundColor = .white
        termsOfServiceButton.layer.cornerRadius = 11
        termsOfServiceButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        termsOfServiceButton.setTitleColor(.black, for: .normal)
        termsOfServiceButton.contentHorizontalAlignment = .left
        termsOfServiceButton.setHeight(40)
        
        view.addSubview(termsOfServiceButton)
        termsOfServiceButton.pinHorizontal(to: tagSettingsButton)
        termsOfServiceButton.pinTop(to: tagSettingsButton.bottomAnchor, 10)
        
        termsOfServiceButton.addTarget(self, action: #selector(termsOfServiceButtonTapped), for: .touchUpInside)
    }
    
    private func configureAboutUsButton() {
        aboutUsButton.setTitle("  О нас", for: .normal)
        aboutUsButton.backgroundColor = .white
        aboutUsButton.layer.cornerRadius = 11
        aboutUsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        aboutUsButton.setTitleColor(.black, for: .normal)
        aboutUsButton.contentHorizontalAlignment = .left
        aboutUsButton.setHeight(40)
        
        view.addSubview(aboutUsButton)
        aboutUsButton.pinHorizontal(to: termsOfServiceButton)
        aboutUsButton.pinTop(to: termsOfServiceButton.bottomAnchor, 10)
        
        aboutUsButton.addTarget(self, action: #selector(aboutUsButtonTapped), for: .touchUpInside)
    }
    
    @objc func deleteAllDataButtonTapped() {
        let alertController = UIAlertController(title: "Подтверждение", message: "Вы действительно безвозратно хотите удалить все данные?", preferredStyle: .alert)
        alertController.view.tintColor = .red
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter?.deleteAllData()
        }
        alertController.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func termsOfServiceButtonTapped() {
        if let url = URL(string: "https://www.termsfeed.com/live/028084dd-b4fb-4b17-afef-e0d85adee53b") {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredBarTintColor = UIColor("f2f2f7")
            safariViewController.preferredControlTintColor = .red
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func aboutUsButtonTapped() {
        if let url = URL(string: "https://github.com/aubhona/TimeManager") {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredBarTintColor = UIColor("f2f2f7")
            safariViewController.preferredControlTintColor = .red
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func tagSettingsButtonTapped() {
        let tagSettingsViewController = TagSettingsViewController()
        tagSettingsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tagSettingsViewController, animated: true)
    }
}
