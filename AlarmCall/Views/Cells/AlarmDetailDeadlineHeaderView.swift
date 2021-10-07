//
//  AlarmDetailDeadlineHeaderView.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import RxSwift

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
