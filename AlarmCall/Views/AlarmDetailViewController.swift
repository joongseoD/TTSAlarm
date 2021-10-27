//
//  AlarmDetailViewController.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class AlarmDetailViewController: UIViewController, ViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        AlarmDetailSection.allCases.forEach {
            tableView.register($0.cellType, forCellReuseIdentifier: $0.reuseIdentifier)
        }
        tableView.register(AlarmDetailDeadlineHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private let doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.style = .done
        button.title = "완료"
        return button
    }()
    
    private var datasource: RxTableViewSectionedReloadDataSource<AlarmDetailSectionModel>!
    private var disposeBag = DisposeBag()
    
    private let viewModel: AlarmDetailViewModel
    
    init(viewModel: AlarmDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpAppearence()
        setUpLayout()
        setUpDataSource()
        bindViewModel()
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemPink
        navigationItem.title = viewModel.isEditMode ? "Edit Alarm" : "New Alarm"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setUpAppearence() {
        view.backgroundColor = .black
    }
    
    private func setUpLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    private func setUpDataSource() {
        datasource = RxTableViewSectionedReloadDataSource<AlarmDetailSectionModel>(configureCell: { datasource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath) as? AlarmDetailTableViewCellType else { return UITableViewCell() }
            cell.configure(item.viewModel)
            cell.selectionStyle = .none
            return cell
        })
    }
    
    private func bindViewModel() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.selectedIndex)
            .disposed(by: disposeBag)
        
        viewModel.sectionModels
            .drive(tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        viewModel.moveToEdit
            .drive(onNext: { [weak self] in
                self?.navigationController?.transition(to: $0)
            })
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(to: viewModel.submitAlarm)
            .disposed(by: disposeBag)
        
        viewModel.completeSubmit
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
    
}

extension AlarmDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard datasource[section].header == .repeat else { return nil }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? AlarmDetailDeadlineHeaderView else { return nil }
        
        headerView.configure(viewModel.toggleDeadline)
        headerView.toggleSwitch.rx.controlEvent(.valueChanged)
            .map { _ in headerView.toggleSwitch.isOn }
            .subscribe(onNext: { [weak self] in
                self?.viewModel.toggleDeadline(enable: $0)
            })
            .disposed(by: headerView.bag)
        
        return headerView
    }
}
