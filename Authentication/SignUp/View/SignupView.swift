//
//  SignupViewType.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/18/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

public protocol SignupViewType: Renderable, SignupFormType { }

internal final class SignupView: UIView, SignupViewType {
    
    internal lazy var delegate: SignupViewDelegate = DefaultSignupViewDelegate()
    
    //TODO return real objects
    internal var usernameLabel: UILabel? { return .None }
    internal var usernameTextField: UITextField? { return .None }
    internal var usernameValidationMessageLabel: UILabel? { return .None }
    
    internal var emailLabel: UILabel? { return .None }
    internal var emailTextField: UITextField { return UITextField() }
    internal var emailValidationMessageLabel: UILabel? { return .None }
    
    internal var passwordLabel: UILabel? { return .None }
    internal var passwordTextField: UITextField { return UITextField() }
    internal var passwordValidationMessageLabel: UILabel? { return .None }
    internal var passwordVisibilityButton: UIButton? { return .None }
    
    internal var passwordConfirmLabel: UILabel? { return .None }
    internal var passwordConfirmTextField: UITextField { return UITextField() }
    internal var passwordConfirmValidationMessageLabel: UILabel? { return .None }
    internal var passwordConfirmVisibilityButton: UIButton? { return .None }
    
    internal var signupButton: UIButton { return UIButton() }
    internal var signupErrorLabel: UILabel? { return .None }
    
    internal var termsAndServicesButton: UIButton { return UIButton() }
    internal var termsAndServicesLabel: UILabel? { return .None }
    
    internal var usernameTextFieldValid = false
    internal var usernameTextFieldSelected = false
    internal var emailTextFieldValid = false
    internal var emailTextFieldSelected = false
    internal var passwordTextFieldValid = false
    internal var passwordTextFieldSelected = false
    internal var showPassword = false
    internal var passwordConfirmationTextFieldValid = false
    internal var passwordConfirmationTextFieldSelected = false
    internal var showConfirmPassword = false
    internal var signupButtonEnabled = false
    internal var signupButtonPressed = false
    
    internal func render() {
        
        delegate.configureView(self)
        
    }
    
}

private extension SignupView {
    
    private var nameText: String {
        return "signup-view.name".localized
    }
    
    private var emailText: String {
        return "signup-view.email".localized
    }
    
    private var passwordText: String {
        return "signup-view.password".localized
    }
    
    private var confirmPasswordText: String {
        return "signup-view.confirm-password".localized
    }
    
    private var namePlaceholderText: String {
        return "signup-view.name-placeholder".localized
    }
    
    private var emailPlaceholderText: String {
        return "signup-view.email-placeholder".localized
    }
    
    private var passwordPlaceholderText: String {
        return "signup-view.password-placeholder".localized
    }
    
    private var confirmPasswordPlaceholderText: String {
        return "signup-view.confirm-password-placeholder".localized
    }
    
    private var termsAndServicesLabelText: String {
        return "signup-view.terms-and-services.label-text".localized
    }
    
    private var termsAndServicesButtonTitle: String {
        return "signup-view.terms-and-services.button-title".localized
    }
    private var signupButtonTitle: String {
        return "signup-view.signup-button-title".localized
    }
    
}
