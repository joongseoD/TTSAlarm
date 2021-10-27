//
//  AlarmTableViewCell.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import UIKit
import RxSwift
import RxCocoa

final class AlarmTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    lazy var stackView: UIStackView = {
        let timeStackView = UIStackView(arrangedSubviews: [timeLabel, middayLabel])
        timeStackView.axis = .horizontal
        timeStackView.distribution = .fill
        timeStackView.alignment = .firstBaseline
        timeStackView.spacing = 1.5
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.addArrangedSubview(timeStackView)
        stackView.addArrangedSubview(descriptionLabel)
        
        return stackView
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 50, weight: .medium)
        timeLabel.textColor = .white
        return timeLabel
    }()
    
    lazy var middayLabel: UILabel = {
        let middayLabel = UILabel()
        middayLabel.font = .systemFont(ofSize: 30, weight: .medium)
        middayLabel.textColor = .white
        return middayLabel
    }()
    
    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = .white
        return descriptionLabel
    }()
    
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .systemPink
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpAppearence()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    private func setUpAppearence() {
        contentView.backgroundColor = .black
        separatorInset = .init(top: 0, left: 15, bottom: 0, right: 0)
        
    }
    
    private func setUpLayout() {
        contentView.addSubview(stackView)
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(17)
        }
                
        contentView.addSubview(toggleSwitch)
        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-15)
            make.centerY.equalTo(contentView)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(15)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-15).priority(.high)
            make.trailing.equalTo(toggleSwitch.snp.leading).offset(-15)
        }
    }
    
    func configure(_ alarm: AlarmCellModel) {
        timeLabel.text = alarm.time
        middayLabel.text = alarm.midday
        descriptionLabel.text = alarm.description
        toggleSwitch.isOn = alarm.isOn
    }
}

extension Reactive where Base: AlarmTableViewCell {
    var tappedToggle: Driver<Bool> {
        base.toggleSwitch.rx.controlEvent(.valueChanged)
            .map { base.toggleSwitch.isOn }
            .asDriver(onErrorJustReturn: false)
    }
}
