//
//  AlarmDetailSelectTableViewCell.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import UIKit
import RxSwift

final class AlarmDetailSelectTableViewCell: UITableViewCell, AlarmDetailTableViewCellType {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    let valueLabel: UILabel = {
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
    
    deinit {
        print("deinit \(String(describing: self))")
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
