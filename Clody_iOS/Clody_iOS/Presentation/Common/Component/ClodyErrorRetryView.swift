//
//  ClodyErrorRetryView.swift
//  Clody_iOS
//
//  Created by Seonwoo Kim on 8/14/24.
//

import UIKit

import SnapKit
import Then

final class ClodyErrorRetryView: BaseView {
    
    // MARK: - UI Components
    
    let errorImage = UIImageView()
    let titleLabel = UILabel()
    lazy var retryButton = UIButton()
    
    override func setStyle() {
        
        self.backgroundColor = .white
                
        errorImage.do {
            $0.image = .errorRetry
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.textColor = .grey04
            $0.attributedText = UIFont.pretendardString(
                text: I18N.Error.unKnown,
                style: .body2_semibold,
                lineHeightMultiple: 1.5
            )
            $0.numberOfLines = 2
            $0.textAlignment = .center
        }
        
        retryButton.do {
            $0.backgroundColor = .mainYellow
            $0.makeCornerRound(radius: 10)
            $0.setTitleColor(.grey02, for: .normal)
            let attributedTitle = UIFont.pretendardString(text: I18N.Alert.retry, style: .body2_semibold)
            $0.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
    
    override func setHierarchy() {
        self.addSubviews(errorImage, titleLabel, retryButton)
    }
    
    override func setLayout() {
        errorImage.snp.makeConstraints {
            $0.width.equalTo(ScreenUtils.getWidth(118))
            $0.height.equalTo(ScreenUtils.getHeight(87))
            $0.leading.equalTo(titleLabel.snp.leading).offset(ScreenUtils.getWidth(36))
            $0.top.equalTo(safeAreaLayoutGuide).inset(ScreenUtils.getHeight(232))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(errorImage.snp.bottom).offset(ScreenUtils.getHeight(30))
        }
        
        retryButton.snp.makeConstraints {
            $0.height.equalTo(ScreenUtils.getHeight(48))
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(ScreenUtils.getHeight(5))
            $0.horizontalEdges.equalToSuperview().inset(ScreenUtils.getWidth(24))
        }
    }

    
    @objc func confirmButtonTapped() {
        self.removeFromSuperview()
    }
}

