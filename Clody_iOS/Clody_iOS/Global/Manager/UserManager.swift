//
//  UserManager.swift
//  Clody_iOS
//
//  Created by Seonwoo Kim on 7/16/24.
//

import Foundation
import KeychainAccess

final class UserManager {
    static let shared = UserManager()
    
    private let keychain = Keychain(service: I18N.Common.bundleID)

    private init() {}
    
    var accessToken: String? {
        get { return keychain["accessToken"] }
        set { keychain["accessToken"] = newValue }
    }
    
    var refreshToken: String? {
        get { return keychain["refreshToken"] }
        set { keychain["refreshToken"] = newValue }
    }
    
    var authCode: String?
    
    var idToken: String? {
        get { return keychain["idToken"] }
        set { keychain["idToken"] = newValue }
    }
    
    var platform: String? {
        get { return keychain["platform"] }
        set { keychain["platform"] = newValue }
    }
    
    var fcmToken: String? {
        get { return keychain["fcmToken"] }
        set { keychain["fcmToken"] = newValue }
    }
    
    var appleEmail: String? {
        get { return keychain["appleEmail"] }
        set { keychain["appleEmail"] = newValue }
    }
    
    var hasAccessToken: Bool { return self.accessToken != nil }
    var accessTokenValue: String { return self.accessToken ?? "" }
    var refreshTokenValue: String { return self.refreshToken ?? "" }
    var authCodeValue: String { return self.authCode ?? "" }
    var idTokenValue: String { return self.idToken ?? "" }
    var platformValue: String { return self.platform ?? "" }
    var fcmTokenValue: String { return self.fcmToken ?? "" }
    var appleEmailValue: String { return self.appleEmail ?? "" }
}

extension UserManager {
    func updateToken(_ accessToken: String, _ refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func updateFcmToken(_ fcmToken: String) {
        self.fcmToken = fcmToken
    }
    
    func clearAll() {
        self.accessToken = nil
        self.refreshToken = nil
        self.idToken = nil
        self.platform = nil
    }
}
