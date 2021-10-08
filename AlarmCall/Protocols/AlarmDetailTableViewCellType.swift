//
//  AlarmDetailTableViewCellType.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/07.
//

import UIKit

protocol AlarmDetailTableViewCellType where Self: UITableViewCell {
    func configure(_ viewModel: AlarmDetailSectionViewModelType)
}
