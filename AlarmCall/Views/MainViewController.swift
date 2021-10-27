//
//  MainViewController.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class MainViewController: UIViewController, ViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        return button
    }()
    
    private var datasources: RxTableViewSectionedReloadDataSource<AlarmSectionModel>!
    
    private var disposeBag = DisposeBag()
    
    private let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpLayout()
        setUpDatasource()
        bindViewModel()
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Alarm"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setUpLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self.view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setUpDatasource() {
        datasources = RxTableViewSectionedReloadDataSource<AlarmSectionModel>(configureCell: { [weak self] datasource, tableView, IndexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: IndexPath) as! AlarmTableViewCell
            cell.configure(item)
            
            cell.rx.tappedToggle
                .drive(onNext: { [weak self] isOn in
                    self?.viewModel.toggle(item.id, isOn: isOn)
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        })
    }
    
    private func bindViewModel() {
        viewModel.alarmSectionModel
            .drive(tableView.rx.items(dataSource: datasources))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.selectedIndex)
            .disposed(by: disposeBag)
        
        viewModel.detailComponent
            .drive(onNext: { [weak self] in
                self?.transition(with: $0)
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .bind(to: viewModel.addAlarmButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func transition(with component: AlarmDetailViewModelDependency) {
        navigationController?.transition(to: .alarmDetail(component: component))
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
