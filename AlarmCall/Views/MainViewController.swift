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

final class MainViewController: UIViewController, ViewControllerType {
    
    typealias ViewModel = MainViewModel
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAlarm))
        return button
    }()
    
    private var datasources: RxTableViewSectionedReloadDataSource<AlarmSectionModel>!
    var viewModel: MainViewModel!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpLayout()
        setUpDatasource()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let recorder = TestToSpeechRecorder()
//        recorder.speack("진아 중서야 오늘은 절대 늦으면 안되는 주일이야. 명일이 오빠가 늦지 말라고 쿠사리줬잖아. 이번에도 늦으면 진심 양심없는 애들로 찍히고 말거야. 명심이 언니 표정 봤니?")
////        recorder.saveRecordFile()
//
//        let center = AlarmReservationCenter()
//        center.reserve(Alarm(comment: "안녕", wakeUpDate: Date(),
//                             deadlineDate: Date(), notificationIntervalMinute: 7, soundFileName: "HI", repeatDays: [], enable: true))
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
        
        viewModel.selectedAlarm
            .drive(onNext: { [weak self] in
                self?.transition(model: $0)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func addNewAlarm() {
        transition(model: nil)
    }
    
    private func transition(model: Alarm?) {
        navigationController?.transition(to: .alarmDetail(id: model?.id, completion: viewModel.refresh))
    }
    
    deinit {
        print("\(String(describing: self)) deinit")
    }
}
