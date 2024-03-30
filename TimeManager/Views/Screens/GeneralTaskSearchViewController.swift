//
//  GeneralTaskSearchScreen.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 29.03.2024.
//

import UIKit

internal final class GeneralTaskSearchViewController: UIViewController {
    private var taskSearchBar: UISearchBar = UISearchBar()
    private var taskTableView: UITableView = UITableView()
    private var swipeIndicatorView: UIView = UIView()
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var initialPosition: CGFloat = 0
    private var presenter: GeneralTaskSearchPresenter?
    private var smallCells: [Bool] = [Bool]()
    public var actionBeforeClose: ((GeneralTaskDto) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter = GeneralTaskSearchPresenter(self, CoreDataGeneralTaskRepository.shared)
        
        configurePanGestureRecognizer()
        configureSwipeIndicator()
        configureViews()
        configureTapGestureRecognizer()
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
        taskSearchBar = UISearchBar()
        taskSearchBar.placeholder = "Начните писать название задачи"
        taskSearchBar.tintColor = .red
        taskSearchBar.delegate = self
        view.addSubview(taskSearchBar)
        taskSearchBar.pinHorizontal(to: view, 20)
        taskSearchBar.pinTop(to: swipeIndicatorView.bottomAnchor, 10)
        
        taskTableView = UITableView(frame: .zero)
        taskTableView.backgroundColor = .clear
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.separatorStyle = .none
        taskTableView.register(SearchGeneralTaskTableViewCell.self, forCellReuseIdentifier: SearchGeneralTaskTableViewCell.reuseIdentifier)
        taskTableView.allowsSelection = true
        taskTableView.allowsMultipleSelection = false
        taskTableView.showsVerticalScrollIndicator = false
        view.addSubview(taskTableView)
        taskTableView.pinTop(to: taskSearchBar.bottomAnchor, 10)
        taskTableView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        taskTableView.pinHorizontal(to: taskSearchBar)
    }
    
    private func configureTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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

extension GeneralTaskSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.filterTask(searchName: searchText)
        UIView.transition(with: taskTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.taskTableView.reloadData() })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

extension GeneralTaskSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = presenter?.getFoundTaskCount() ?? 0
        smallCells = Array(repeating: false, count: count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchGeneralTaskTableViewCell.reuseIdentifier, for: indexPath)
        guard let generalTaskCell = cell as? SearchGeneralTaskTableViewCell else { return cell }
        guard let task = presenter?.getFoundTask(index: indexPath.row) else { return cell }
        generalTaskCell.configure(task: task)
        smallCells[indexPath.row] = generalTaskCell.isSmall
        return generalTaskCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return smallCells[indexPath.row] ? 80 : 130
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = presenter?.getFoundTask(index: indexPath.row) else { return }
        actionBeforeClose?(task)
        self.dismiss(animated: true, completion: nil)
    }
}

