//
//  GetCloverAlertView.swift
//  Clody_iOS
//
//  Created by 김나연 on 7/14/24.
//

import UIKit

import SnapKit
import Then

final class GetCloverAlertView: BaseView {
    
    private let cloverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    let okButton = UIButton()
    
    private var nickname: String
    
    init(nickname: String) {
        self.nickname = nickname
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyle() {
        backgroundColor = .white
        makeCornerRound(radius: 12)
        
        cloverImageView.do {
            $0.image = .imgFourLeafClover
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.textColor = .grey05
            $0.attributedText = UIFont.pretendardString(
                text: nickname + I18N.Reply.goodLuckToYou,
                style: .detail1_medium,
                color: .grey05
            )
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        contentLabel.do {
            $0.textColor = .grey01
            $0.attributedText = UIFont.pretendardString(
                text: I18N.Reply.getClover,
                style: .head3,
                color: .grey01
            )
        }
        
        okButton.do {
            $0.setTitleColor(.darkYellow, for: .normal)
            $0.setAttributedTitle(
                UIFont.pretendardString(
                    text: I18N.Common.ok,
                    style: .body2_semibold
                ),
                for: .normal
            )
        }
    }
    
    override func setHierarchy() {
        self.addSubviews(cloverImageView, titleLabel, contentLabel, okButton)
    }
    
    override func setLayout() {
        cloverImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(cloverImageView.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        okButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(contentLabel.snp.bottom).offset(21.5)
            $0.horizontalEdges.equalToSuperview().inset(11)
            $0.bottom.equalToSuperview().inset(11.5)
        }
    }
}
