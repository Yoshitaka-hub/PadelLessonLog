//
//  BaseViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/12.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    static let forbidHideKeyboardTag: Int = 9001
    var keyboardShowing = false
    var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        watchingKeyboardStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        watchingKeyboardStatus()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        releaseWatchingKeyboard()
    }
    
    func watchingKeyboardStatus() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func releaseWatchingKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func hideKeyboardWhenTapped() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture!.delegate = self
        view.addGestureRecognizer(tapGesture!)
    }

    func cancelHideKeyboard() {
        if let tap = self.tapGesture {
            view.removeGestureRecognizer(tap)
        }
    }

    @objc func dismissKeyboard() {
        if keyboardShowing {
            view.endEditing(true)
        }
    }

    @objc func keyboardDidShow(notification: Notification) {
        keyboardShowing = true
        hideKeyboardWhenTapped()
    }

    @objc func keyboardDidHide(notification: Notification) {
        keyboardShowing = false
        cancelHideKeyboard()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return keyboardShowing && touch.view?.tag != BaseViewController.forbidHideKeyboardTag
    }
}
