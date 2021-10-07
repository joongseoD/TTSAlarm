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

class AlarmDetailViewController: UIViewController, ViewControllerType {
    
    var viewModel: AlarmDetailViewModel!
    
    lazy var tableView: UITableView = {
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
    
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.style = .done
        button.title = "완료"
        return button
    }()
    
    private var datasource: RxTableViewSectionedReloadDataSource<AlarmDetailSectionModel>!
    private var disposeBag = DisposeBag()
    
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
        navigationItem.title = "Alarm Detail"
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
        
        viewModel.sectionModels
            .drive(tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        viewModel.currentAlarm
            .drive(onNext: { [weak self] alarm in
                self?.navigationItem.title = alarm == nil ? "New Alarm" : "Edit Alarm"
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

final class AlarmDetailSelectTableViewCell: UITableViewCell, AlarmDetailTableViewCellType {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpAppearence()
        setUpLayout()
    }
    
    private func setUpAppearence() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        accessoryType = .disclosureIndicator
    }
    
    private func setUpLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.height.equalTo(50)
            make.leading.equalTo(contentView).offset(15)
            make.width.equalTo(contentView).multipliedBy(0.35)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-15)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.leading.equalTo(self)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
        }
    }
    
    func configure(_ viewModel: AlarmDetailSectionViewModelType) {
        guard let viewModel = viewModel as? AlarmDetailSelectSectionViewModel else { return }
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
}

final class AlarmDetailDatePickerTableViewCell: UITableViewCell, AlarmDetailTableViewCellType, ConvenyingChangedDate {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.datePickerMode = .time
        picker.locale = Locale(identifier: "ko-KR")
        picker.timeZone = .autoupdatingCurrent
        return picker
    }()
    
    var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpAppearence()
        setUpLayout()
    }
    
    private func setUpAppearence() {
        backgroundColor = .black
        contentView.backgroundColor = .black
    }
    
    private func setUpLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(datePicker)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(15)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20).priority(.high)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView).offset(15).priority(.high)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func configure(_ viewModel: AlarmDetailSectionViewModelType) {
        guard let viewModel = viewModel as? AlarmDetailDateSectionViewModel else { return }
        titleLabel.text = viewModel.title
        datePicker.date = viewModel.date ?? Date()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    var changedDate = PublishSubject<Date>()
}

protocol ConvenyingChangedDate {
    var changedDate: PublishSubject<Date> { get set }
}

protocol AlarmDetailTableViewCellType where Self: UITableViewCell {
    func configure(_ viewModel: AlarmDetailSectionViewModelType)
}

final class AlarmDetailDeadlineHeaderView: UITableViewHeaderFooterView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.text = "반복 설정"
        return label
    }()
    
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.tintColor = .systemPink
        return toggle
    }()
    
    var bag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setUpAppearence()
        setUpLayout()
    }
    
    private func setUpAppearence() {
        contentView.backgroundColor = .black
    }
    
    private func setUpLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(toggleSwitch.snp.leading).offset(10)
        }

        toggleSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func configure(_ enable: Bool) {
        toggleSwitch.isOn = enable
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
}
