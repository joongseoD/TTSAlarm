//
//  NavigationBarView.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/05.
//

import SnapKit
import RxSwift
import RxCocoa

final class NavigationBarView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 5
        stackView.backgroundColor = .darkGray
        stackView.addArrangedSubview(leftButton)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(rightButton)
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let leftButton: UIButton = {
        let backButton = UIButton()
        backButton.setTitle("Back", for: .normal)
        return backButton
    }()
    
    fileprivate let rightButton: UIButton = {
        let optionButton = UIButton()
        optionButton.alpha = 0
        optionButton.setTitle("option", for: .normal)
        return optionButton
    }()
    
    override var backgroundColor: UIColor? {
        didSet {
            containerView.backgroundColor = backgroundColor
            stackView.backgroundColor = backgroundColor
        }
    }
    
    var foregroundColor: UIColor? = .white {
        didSet {
            titleLabel.textColor = foregroundColor
            leftButton.setTitleColor(foregroundColor, for: .normal)
            rightButton.setTitleColor(foregroundColor, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    convenience init(title: String, leftEnable: Bool = false, rightEnable: Bool = false) {
        self.init(frame: .zero)
        
        self.titleLabel.text = title
        self.leftButton.alpha = !leftEnable ? 0 : 1
        self.rightButton.alpha = !rightEnable ? 0 : 1
    }
    
    private func setUpLayout() {
        addSubview(containerView)
        addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self).offset(15)
            make.trailing.equalTo(self).offset(-15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(self).multipliedBy(0.6)
        }
        
        self.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(containerView)
            make.bottom.equalTo(stackView.snp.bottom)
        }
    }
}

extension Reactive where Base: NavigationBarView {
    var tappedLeftButton: Driver<Void> {
        return base.leftButton.rx.tap.asDriver()
    }
    
    var tappedRightButton: Driver<Void> {
        return base.rightButton.rx.tap.asDriver()
    }
}
