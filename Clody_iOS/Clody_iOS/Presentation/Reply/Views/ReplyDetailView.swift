//
//  ReplyDetailView.swift
//  Clody_iOS
//
//  Created by 김나연 on 7/14/24.
//

import UIKit

import SnapKit
import Then

final class ReplyDetailView: BaseView {
    
    lazy var navigationBar = ClodyNavigationBar(type: .reply, title: "\(month)월 \(date)일")
    private let backgroundView = UIView()
    private let rodyImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var replyTextView = UITextView()
    
    private let month: Int
    private let date: Int
    private let nickname: String
    private let content: String
    
    init(
        month: Int,
        date: Int,
        nickname: String,
        content: String
    ) {
        self.month = month
        self.date = date
        self.nickname = nickname
        self.content = content
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyle() {
        backgroundColor = .white
        
        backgroundView.do {
            $0.backgroundColor = .grey08
            $0.makeCornerRound(radius: 13)
        }
        
        rodyImageView.do {
            $0.image = .imgReplyRody
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            let title = nickname + I18N.Reply.luckyReplyForYou
            $0.textColor = .grey01
            $0.attributedText = UIFont.pretendardString(text: title, style: .body2_semibold)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        replyTextView.do {
            $0.backgroundColor = .clear
            $0.textColor = .grey02
            $0.attributedText = UIFont.pretendardString(
                text: content,
                style: .letter_medium,
                lineHeightMultiple: 1.9
            )
            $0.isScrollEnabled = true
            $0.showsVerticalScrollIndicator = false
            $0.isEditable = false
        }
    }
    
    override func setHierarchy() {
        self.addSubviews(navigationBar, backgroundView)
        backgroundView.addSubviews(rodyImageView, titleLabel, replyTextView)
    }
    
    override func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(7)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(28)
        }
        
        rodyImageView.snp.makeConstraints {
            $0.size.equalTo(ScreenUtils.getHeight(95))
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(rodyImageView.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
        }
        
        replyTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(ScreenUtils.getHeight(40))
        }
    }
}
