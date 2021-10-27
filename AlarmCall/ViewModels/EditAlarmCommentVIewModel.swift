//
//  EditAlarmCommentVIewModel.swift
//  AlarmCall
//
//  Created by Damor on 2021/10/08.
//

import RxSwift
import RxCocoa

protocol EditAlarmCommentViewModelDependency {
    var previousComment: String { get }
    var editCompletion: ((String) -> Void)? { get }
}

final class EditAlarmCommentViewModel: ViewModel {
    private let _comment = PublishSubject<String>()
    private let _submit = PublishSubject<Void>()
    private let _editCompleted = PublishSubject<Void>()
    private let _speakVoice = PublishSubject<Void>()
    private var bag = DisposeBag()
    private let dependency: EditAlarmCommentViewModelDependency
    private var completion: ((String) -> Void)?
    let previousComment: String
    
    init(dependency: EditAlarmCommentViewModelDependency) {
        self.dependency = dependency
        self.previousComment = dependency.previousComment
        self.completion = dependency.editCompletion
        
        setUp()
    }
    
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    private func setUp() {
        _submit
            .withLatestFrom(_comment)
            .subscribe(onNext: { [weak self] comment in
                self?.completion?(comment)
                self?._editCompleted.onNext(())
            })
            .disposed(by: bag)
        
        _speakVoice
            .withLatestFrom(_comment)
            .subscribe(onNext: { comment in
                let voice = TTSRecorder(text: comment)
                voice.speack()
            })
            .disposed(by: bag)
    }
}

extension EditAlarmCommentViewModel {
    var comment: Binder<String> {
        return Binder(self) { viewModel, comment in
            viewModel._comment.onNext(comment)
        }
    }
    
    var submit: Binder<Void> {
        return Binder(self) { viewModel, _ in
            viewModel._submit.onNext(())
        }
    }
    
    var speak: Binder<Void> {
        return Binder(self) { viewModel, _ in
            viewModel._speakVoice.onNext(())
        }
    }
}

extension EditAlarmCommentViewModel {
    var editCompleted: Observable<Void> {
        return _editCompleted.asObservable()
    }
}

