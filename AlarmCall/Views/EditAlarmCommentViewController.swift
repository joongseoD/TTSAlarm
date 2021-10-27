//
//  EditAlarmCommentViewController.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class EditAlarmCommentViewController: UIViewController, ViewController {

    private let textView: UITextView = {
        let textView = UITextView()
        let color = UIColor(white: 20.0 / 255.0, alpha: 1.0)
        textView.layer.cornerRadius = 15
        textView.layer.borderColor = color.cgColor
        textView.layer.borderWidth = 0.5
        textView.clipsToBounds = true
        textView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
        textView.backgroundColor = color
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 18)
        return textView
    }()
    
    private let speakButton: UIButton = {
        let button = UIButton()
        button.setTitle("들어보기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.style = .done
        button.title = "완료"
        return button
    }()
    
    private var bag = DisposeBag()
    private let viewModel: EditAlarmCommentViewModel
    
    init(viewModel: EditAlarmCommentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAppearence()
        setUpNavigationBar()
        setUpLayout()
        bindViewModel()
    }
    
    private func setUpAppearence() {
        view.backgroundColor = .black
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemPink
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Alarm Message"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setUpLayout() {
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(25)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-25)
            make.height.equalTo(180)
        }
        
        view.addSubview(speakButton)
        speakButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(15)
            make.leading.trailing.equalTo(textView)
            make.height.equalTo(60)
        }
    }
    
    private func bindViewModel() {
        textView.text = viewModel.previousComment
        
        textView.rx.text.orEmpty
            .bind(to: viewModel.comment)
            .disposed(by: bag)
        
        doneButton.rx.tap
            .bind(to: viewModel.submit)
            .disposed(by: bag)
        
        speakButton.rx.tap
            .bind(to: viewModel.speak)
            .disposed(by: bag)
        
        viewModel.editCompleted
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
}

