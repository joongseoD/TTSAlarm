//
//  AlarmDetailDatePickerTableViewCell.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import RxSwift

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
