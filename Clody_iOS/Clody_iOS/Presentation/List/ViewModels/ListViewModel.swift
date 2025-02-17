//
//  ListViewModel.swift
//  Clody_iOS
//
//  Created by Seonwoo Kim on 7/10/24.
//

import UIKit

import RxSwift
import RxCocoa

final class ListViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let tapReplyButton: Signal<String>
        let tapKebabButton: Signal<String>
        let tapCalendarButton: Signal<Void>
        let tapDateButton: Signal<Void>
        let monthTap: Signal<String>
        let tapDeleteButton: Signal<Void>
    }
    
    struct Output {
        let replyDate: Driver<String>
        let kebabDate: Driver<String>
        let changeToCalendar: Signal<Void>
        let showPickerView: Signal<Void>
        let changeNavigationDate: Driver<String>
        let listDataChanged: Driver<[ListDiary]>
        let showDelete: Signal<Void>
        let isLoading: Driver<Bool>
        let errorStatus: Driver<String>
    }
    
    let listDataRelay = BehaviorRelay<CalendarListResponseDTO>(value: CalendarListResponseDTO(totalCloverCount: 0, diaries: []))
    let selectedMonthRelay = BehaviorRelay<[String]>(value: ["", ""])
    let selectedDateRelay = BehaviorRelay<String?>(value: nil)
    let isLoadingRelay = PublishRelay<Bool>()
    let errorStatusRelay = PublishRelay<String>()
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        
        input.viewDidLoad
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                fetchData()
            })
            .disposed(by: disposeBag)
        
        input.tapKebabButton
            .emit(onNext: { [weak self] date in
                self?.selectedDateRelay.accept(date)
            })
            .disposed(by: disposeBag)
        
        let replyDate = input.tapReplyButton
            .asDriver(onErrorJustReturn: "")
        
        let kebabDate = input.tapKebabButton
            .asDriver(onErrorJustReturn: "")
        
        let listDataChanged = listDataRelay
            .map { $0.diaries }
            .asDriver(onErrorJustReturn: [])
        
        let changeToCalendar = input.tapCalendarButton.asSignal()
        
        let showDeleteBottomSheet = input.tapKebabButton.asSignal()
        
        let showPickerView = input.tapDateButton.asSignal()
        
        let changeNavigationDate = selectedMonthRelay
            .observe(on: MainScheduler.asyncInstance)
            .map { date -> String in
                let year = self.selectedMonthRelay.value[0]
                let month = self.selectedMonthRelay.value[1]
                
                self.getListData(year: Int(year) ?? 0, month: Int(month) ?? 0)
                
                let convertYear = date[0]
                guard let convertMonth = DateFormatter.convertToDoubleDigitMonth(from: date[1]) else { return "" }
                let dateSelected = "\(convertYear)년 \(convertMonth)월"
                return dateSelected
            }
            .asDriver(onErrorJustReturn: "Error")
        
        let showDelete = input.tapDeleteButton.asSignal()
        
        let isLoading = isLoadingRelay.asDriver(onErrorJustReturn: false)
        
        let errorStatus = errorStatusRelay.asDriver(onErrorJustReturn: "")
        
        return Output(
            replyDate: replyDate,
            kebabDate: kebabDate,
            changeToCalendar: changeToCalendar,
            showPickerView: showPickerView,
            changeNavigationDate: changeNavigationDate,
            listDataChanged: listDataChanged,
            showDelete: showDelete,
            isLoading: isLoading,
            errorStatus: errorStatus
        )
    }
}

extension ListViewModel {
    
    func fetchData() {
        let selectedDate = selectedMonthRelay.value
        let year = Int(selectedDate[0]) ?? {
            let today = Date()
            return Int(DateFormatter.string(from: today, format: "yyyy")) ?? 0
        }()
        
        let month = Int(selectedDate[1]) ?? {
            let today = Date()
            return Int(DateFormatter.string(from: today, format: "MM")) ?? 0
        }()
        
        self.getListData(year: year, month: month)
        self.selectedMonthRelay.accept([String(year), String(month)])
    }
    
    func getListData(year: Int, month: Int) {
        isLoadingRelay.accept(true)
        let provider = Providers.calendarProvider
        
        provider.request(target: .getListCalendar(year: year, month: month), instance: BaseResponse<CalendarListResponseDTO>.self, completion: { data in
            switch data.status {
            case 200..<300:
                guard let data = data.data else { return }
                self.listDataRelay.accept(data)
            case -1:
                self.errorStatusRelay.accept("networkView")
            default:
                self.errorStatusRelay.accept("unknownedView")
            }
            self.isLoadingRelay.accept(false)
        })
    }
    
    func deleteDiary(year: Int, month: Int, date: Int) {
        isLoadingRelay.accept(true)
        let provider = Providers.diaryRouter
        
        provider.request(target: .deleteDiary(year: year, month: month, date: date), instance: BaseResponse<EmptyResponseDTO>.self, completion: { data in
            switch data.status {
            case 200..<300:
                guard let data = data.data else { return }
                self.getListData(year: year, month: month)
            case -1:
                self.errorStatusRelay.accept("networkView")
            default:
                self.errorStatusRelay.accept("unknownedView")
            }
            self.isLoadingRelay.accept(false)
        })
    }
}

