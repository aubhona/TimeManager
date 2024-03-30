//
//  ViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 25.03.2024.
//

import UIKit

internal final class DatePickerViewController: UIViewController {
    
    private var datePicker = UIDatePicker()
    private var goToDateButton = UIButton()
    private var swipeIndicatorView: UIView = UIView()
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var initialPosition: CGFloat = 0
    public var goToDateAction: ((Date) -> Void)?
    public var currentDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureSwipeIndicator()
        configurePanGestureRecognizer()
        configureGoToDateButton()
        configureDatePicker()
    }
    
    private func configureDatePicker() {
        datePicker = UIDatePicker()
        datePicker.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        datePicker.calendar.firstWeekday = 2
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.tintColor = .red
        datePicker.date = currentDate
        datePicker.locale = Locale(identifier: "ru_RU")
        view.addSubview(datePicker)
        datePicker.pinTop(to: swipeIndicatorView.bottomAnchor, 10)
        datePicker.pinBottom(to: goToDateButton.topAnchor, 10)
        datePicker.pinHorizontal(to: view)
    }
    
    private func configureGoToDateButton() {
        goToDateButton = UIButton(type: .system)
        goToDateButton.layer.cornerRadius = 15
        goToDateButton.setTitle("Перейти", for: .normal)
        goToDateButton.backgroundColor = .red
        goToDateButton.setTitleColor(.white, for: .normal)
        goToDateButton.addTarget(self, action: #selector(toggleDatePicker), for: .touchUpInside)
        
        view.addSubview(goToDateButton)
        goToDateButton.pinHorizontal(to: view, 70)
        goToDateButton.setHeight(35)
        goToDateButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        
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
    
    @objc func toggleDatePicker() {
        goToDateAction?(datePicker.date)
        self.dismiss(animated: true, completion: nil)
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
