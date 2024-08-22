//
//  ReplyWaitingViewController.swift
//  Clody_iOS
//
//  Created by 김나연 on 7/14/24.
//

import UIKit

import RxCocoa
import RxSwift
import Then

final class ReplyWaitingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = ReplyWaitingViewModel()
    private let disposeBag = DisposeBag()
    private var totalSeconds = 30
    private var date: Date
    private var isNew: Bool
    private let isHomeBackButton: Bool
    private let secondsToWaitForFirstReply = 60
    private let secondsToWaitForNormalReply = 12 * 60 * 60
    
    // MARK: - UI Components
     
    private let rootView = ReplyWaitingView()
    private lazy var timeLabel = rootView.timeLabel
    private lazy var openButton = rootView.openButton
    
    // MARK: - Life Cycles
    
    init(date: Date, isNew: Bool, isHomeBackButton: Bool) {
        self.date = date
        self.isNew = isNew
        self.isHomeBackButton = isHomeBackButton
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setUI()
    }
}

// MARK: - Extensions

private extension ReplyWaitingViewController {

    func bindViewModel() {
        rootView.navigationBar.backButton.rx.tap
            .subscribe(onNext: {
                if self.isHomeBackButton {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let timer = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { self.totalSeconds - $0 }
            .take(until: { $0 < 0 })
        
        let input = ReplyWaitingViewModel.Input(
            viewDidLoad: Observable.just(()).asSignal(onErrorJustReturn: ()),
            timer: timer,
            openButtonTapEvent: openButton.rx.tap.asSignal()
        )
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.getWritingTime
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let dateTuple = date.dateToYearMonthDay()
                self.getWritingTime(for: dateTuple)
            })
            .disposed(by: disposeBag)
        
        output.timeLabelDidChange
            .drive(onNext: { [weak self] timeString in
                self?.timeLabel.attributedText = UIFont.pretendardString(
                    text: timeString,
                    style: .head2
                )
            })
            .disposed(by: disposeBag)
        
        output.replyArrivalEvent
            .drive(onNext: { [weak self] in
                self?.rootView.setReplyArrivedView()
                self?.rootView.openButton.setEnabledState(to: true)
            })
            .disposed(by: disposeBag)
        
        output.getReply
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.getReply(date: self.date)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorStatus
            .bind(onNext: { networkViewJudge in
                switch networkViewJudge {
                case .network:
                    self.showRetryView(isNetworkError: true) {
                        self.getWritingTime(for: self.date.dateToYearMonthDay())                        
                    }
                case .unknowned:
                    self.showRetryView(isNetworkError: false) {
                        self.getWritingTime(for: self.date.dateToYearMonthDay())
                    }
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
    }

    func setUI() {
        self.navigationController?.isNavigationBarHidden = true
    }
}

private extension ReplyWaitingViewController {
    
    func getWritingTime(for date: (Int, Int, Int)) {
        viewModel.getWritingTime(year: date.0, month: date.1, date: date.2) { data in
            
            let todayYear = Date().dateToYearMonthDay().0
            let todayMonth = Date().dateToYearMonthDay().1
            let todayDay = Date().dateToYearMonthDay().2
            
            // TODO: 최초 1회 답장인지 분기 처리
            
            if date.0 == todayYear,
               date.1 == todayMonth,
               date.2 == todayDay {
                // 오늘 작성한 일기라면
                let createdTime = (data.HH * 3600) + (data.MM * 60) + data.SS
                let remainingTime = (createdTime + self.secondsToWaitForNormalReply) - Date().currentTimeSeconds()
                self.totalSeconds = (remainingTime <= 0) ? 0 : remainingTime
            } else {
                // 어제 작성한 일기라면
                let calendar = Calendar.current
                let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: Date())!
                let writingTime = calendar.date(bySettingHour: data.HH, minute: data.MM, second: data.SS, of: yesterdayDate)!
                let twelveHoursLater = writingTime.addingTimeInterval(Double(self.secondsToWaitForNormalReply))
                
                let remainingTime = Int(twelveHoursLater.timeIntervalSinceNow)
                self.totalSeconds = (remainingTime <= 0) ? 0 : remainingTime
            }
        }
    }
    
    func getReply(date: Date) {
        
        let year = DateFormatter.string(from: date, format: "yyyy")
        let month = DateFormatter.string(from: date, format: "MM")
        let date = DateFormatter.string(from: date, format: "dd")
        
        viewModel.getReply(year: Int(year) ?? 0, month: Int(month) ?? 0, date: Int(date) ?? 0) { data in
            self.navigationController?.pushViewController(
                ReplyDetailViewController(data: data, isNew: self.isNew),
                animated: true
            )
        }
    }
}
