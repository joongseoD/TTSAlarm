//
//  EditAlarmCommentViewController.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class EditAlarmRepeatDaysViewController: UIViewController, ViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EditAlarmSelectableTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private var bag = DisposeBag()
    
    private let viewModel: EditAlarmRepeatDaysViewModel
    
    init(viewModel: EditAlarmRepeatDaysViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpLayout()
        bindViewModel()
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Alarm" // TODO
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func setUpLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self.view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func bindViewModel() {
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: EditAlarmSelectableTableViewCell.self)) { index, wrappedItem, cell in
                
                cell.titleLabel.text = "\(wrappedItem.item)"
                cell.selectImageView.isHidden = !wrappedItem.isSelected
            }
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.selectedIndex)
            .disposed(by: bag)
    }
}
