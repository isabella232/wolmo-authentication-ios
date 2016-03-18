//
//  LoginViewDelegate.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/18/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation

public protocol LoginViewDelegate {
    
    func configureView(loginView: LoginViewType)
    
}

public extension LoginViewDelegate {
    
    func configureView(loginView: LoginViewType) {
        
    }
    
}

public final class DefaultLoginViewDelegate: LoginViewDelegate { }
