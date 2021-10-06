//
//  AlarmDetailViewController.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit

class AlarmDetailViewController: UIViewController, ViewControllerType {
    
    var viewModel: AlarmDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpAppearence()
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemPink
        navigationItem.title = "Alarm Detail"
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func setUpAppearence() {
        view.backgroundColor = .black
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
}
