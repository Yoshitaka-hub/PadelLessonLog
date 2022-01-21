//
//  SettingTableViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/13.
//

import UIKit

class SettingTableViewController: UITableViewController {
    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アプリバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
    }
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
}
