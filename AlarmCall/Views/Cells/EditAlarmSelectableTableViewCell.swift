//
//  EditAlarmSelectableTableViewCell.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import UIKit

final class EditAlarmSelectableTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let selectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .blue
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    private func setUpLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectImageView)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(15)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(selectImageView.snp.leading).offset(-15)
        }
        
        selectImageView.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-15)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(50)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
