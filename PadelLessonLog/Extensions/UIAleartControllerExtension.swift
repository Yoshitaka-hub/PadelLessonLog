//
//  UIAleartControllerExtension.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/10.
//

import UIKit

extension UIAlertController {
    func addOkAction(title: String?, handler: (() -> Void)?) -> UIAlertController {
        guard title != nil else { return self }
        let action = UIAlertAction(title: title, style: .default, handler: { _ in handler?() })
        addAction(action)
        return self
    }

    func addCancelAction(title: String?, handler: (() -> Void)?) -> UIAlertController {
        guard title != nil else { return self }
        let action = UIAlertAction(title: title, style: .cancel, handler: { _ in handler?() })
        addAction(action)
        return self
    }

    func addDestructiveAction(title: String?, handler: (() -> Void)?) -> UIAlertController {
        guard title != nil else { return self }
        let action = UIAlertAction(title: title, style: .destructive, handler: { _ in handler?() })
        addAction(action)
        return self
    }

    func show(in viewController: UIViewController, completion: (() -> Void)? = nil) {
        viewController.present(self, animated: true, completion: completion)
    }
}
