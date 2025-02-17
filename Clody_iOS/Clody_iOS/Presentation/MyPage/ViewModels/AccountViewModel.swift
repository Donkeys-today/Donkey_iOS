import RxCocoa
import RxSwift

final class AccountViewModel: ViewModelType {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let textFieldInputEvent: Signal<String>
        let textFieldDidBeginEditing: Signal<Void>
        let textFieldDidEndEditing: Signal<Bool>
        let changeNicknameButtonTapEvent: Signal<Void>
        let backButtonTapEvent: Signal<Void>
    }
    
    struct Output {
        let getUserInfo: Driver<Void>
        let charCountDidChange: Driver<String>
        let isTextFieldFocused: Driver<Bool>
        let isDoneButtonEnabled = BehaviorRelay<Bool>(value: false)
        let errorMessage: Driver<TextFieldInputResult>
        let changeNickname: Driver<Void>
        let popViewController: Driver<Void>
    }
    
    let getUserInfoErrorStatus = PublishRelay<NetworkViewJudge>()
    let patchNicknameErrorStatus = PublishRelay<NetworkViewJudge>()
    
    func transform(from input: Input, disposeBag: RxSwift.DisposeBag) -> Output {
        let getUserInfo = input.viewDidLoad
            .asDriver(onErrorJustReturn: ())
        
        let charCountDidChange = input.textFieldInputEvent
            .asDriver(onErrorJustReturn: "")
        
        let isTextFieldFocused = Signal
            .merge(
                input.textFieldDidBeginEditing.map { true },
                input.textFieldDidEndEditing
            )
            .asDriver(onErrorJustReturn: false)
        
        let errorMessage = input.textFieldInputEvent
            .map { text in
                if text.count == 0 { return TextFieldInputResult.empty }
                
                let nicknameRegEx = "^[가-힣a-zA-Z0-9]+${1,10}"
                if let _ = text.range(of: nicknameRegEx, options: .regularExpression) {
                    return TextFieldInputResult.normal
                } else {
                    return TextFieldInputResult.error
                }
            }
            .asDriver(onErrorJustReturn: TextFieldInputResult.empty)
        
        let changeNickname = input.changeNicknameButtonTapEvent
            .asDriver(onErrorJustReturn: ())
        
        let popViewController = input.backButtonTapEvent
            .asDriver(onErrorJustReturn: Void())
                
        return Output(
            getUserInfo: getUserInfo,
            charCountDidChange: charCountDidChange,
            isTextFieldFocused: isTextFieldFocused,
            errorMessage: errorMessage,
            changeNickname: changeNickname,
            popViewController: popViewController
        )
    }
}

extension AccountViewModel {
    
    func getUserInfo(completion: @escaping (GetAccountResponseDTO) -> ()) {
        Providers.myPageProvider.request(target: .getAccount, instance: BaseResponse<GetAccountResponseDTO>.self) { response in
            switch response.status {
            case 200..<300:
                guard let data = response.data else { return }
                self.getUserInfoErrorStatus.accept(.success)
                completion(data)
            case -1:
                self.getUserInfoErrorStatus.accept(.network)
            default:
                self.getUserInfoErrorStatus.accept(.unknowned)
            }
        }
    }
    
    func patchNickName(nickname: String, completion: @escaping (PatchNicknameResponseDTO) -> ()) {
        Providers.myPageProvider.request(target: .patchNickname(data: PatchNicknameRequestDTO(name: nickname)), instance: BaseResponse<PatchNicknameResponseDTO>.self) { response in
            switch response.status {
            case 200..<300:
                guard let data = response.data else { return }
                self.patchNicknameErrorStatus.accept(.success)
                completion(data)
            case -1:
                self.patchNicknameErrorStatus.accept(.network)
            default:
                self.patchNicknameErrorStatus.accept(.unknowned)
            }
        }
    }
    
    func logout(completion: @escaping () -> ()) {
        UserManager.shared.clearAll()
        completion()
    }

    func withdraw(completion: @escaping (NetworkViewJudge) -> ()) {
        Providers.authProvider.request(target: .revoke, instance: BaseResponse<EmptyResponseDTO>.self) { response in
            switch response.status {
            case 200..<300: 
                UserManager.shared.clearAll()
                completion(.success)
            case -1:
                completion(.network)
            default:
                completion(.unknowned)
            }
        }
    }
}
