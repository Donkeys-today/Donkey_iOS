//
//  CalendarViewController.swift
//  Clody_iOS
//
//  Created by Seonwoo Kim on 6/28/24.
//

import UIKit

import FSCalendar
import RxCocoa
import RxSwift
import SnapKit
import Then

final class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalendarViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
     
    private let rootView = CalendarView()
    
    // MARK: - Life Cycles
    
    override func loadView() {
        super.loadView()
        
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setUI()
        setAddTarget()
        registerCells()
        setDelegate()
    }
}

// MARK: - Extensions

private extension CalendarViewController {

    func bindViewModel() {
//        viewModel.isLoginButtonEnabled
//            .bind(to: loginButton.rx.isEnabled)
//            .disposed(by: disposeBag)
    }

    func setUI() { // 탭바, 내비바, 그외 ...
    }
    
    func setDelegate() {
        rootView.calendarCollectionView.dataSource = self
    }
    
    func setAddTarget() {
    }
    
    func registerCells() {
        rootView.calendarCollectionView.register(CalendarCollectionView.self, forCellWithReuseIdentifier: CalendarCollectionView.description())
        rootView.calendarCollectionView.register(DailyCalendarCollectionViewCell.self, forCellWithReuseIdentifier: DailyCalendarCollectionViewCell.description())
        
        rootView.calendarCollectionView.register(DailyCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DailyCalendarHeaderView.description())
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 5
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionView.description(), for: indexPath)
                    as? CalendarCollectionView else { return UICollectionViewCell() }
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyCalendarCollectionViewCell.description(), for: indexPath)
                    as? DailyCalendarCollectionViewCell else { return UICollectionViewCell() }
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            switch indexPath.section {
            case 1:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DailyCalendarHeaderView.description(), for: indexPath) as? DailyCalendarHeaderView else { return UICollectionReusableView() }
                
                return header
                
            default:
                return UICollectionReusableView()
            }
            
        default:
            return UICollectionReusableView()
        }
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {

        guard let cell = calendar.dequeueReusableCell(withIdentifier: CalenderDateCell.description(), for: date, at: position) as? CalenderDateCell else { return FSCalendarCell() }
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return .black
    }
}
