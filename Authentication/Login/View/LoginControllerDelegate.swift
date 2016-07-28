//
//  LoginControllerDelegate.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/15/16.
//  Copyright © 2016 Wolox. All rights reserved.
//


/**
    Protocol for login controller delegates,
    that add behaviour to certain events from
    the login process.
*/
public protocol LoginControllerDelegate {
    
    /**
        Property indicating if the login errors
        should be shown with an alert, apart from
        the login errors label if it exists.
        
        By default, true.
    */
    var shouldDisplayLoginErrorWithAlert: Bool { get }

    /**
        Function called when the login action begins executing,
        before setting the `logInButtonPressed` property of the view used.
        
        By default, it clears old errors from label and
        activates the Network Activity Indicator in the status bar.
     
        - Parameter controller: LoginController where the event is happening.
    */
    func willExecuteLogIn(controller: LoginController)
    
    /**
        Function called when the login action ended with success,
        before setting the `logInButtonPressed` property of the view used.
        
        By default, it deactivates the Network Activity Indicator in the status bar.
     
        - Parameter controller: LoginController where the event is happening.
     */
    func didExecuteLogIn(controller: LoginController)
    
    /**
        Function called when the login action ended with error,
        before setting the `logInButtonPressed` property of the view used.
        
        By default, it deactivates the Network Activity Indicator in the status bar,
        fills the error label with the error message and if the property
        `shouldDisplayLoginErrorWithAlert` is set to true, shows an alert with the error.
     
        - Parameter controller: LoginController where the event is happening.
        - Parameter with: error resulting from the log in attempt.
     */
    func didLogIn(controller: LoginController, with error: SessionServiceError)
    
    /**
        Function called when any new email introduced is valid,
        before setting the `emailTextFieldValid` property of the view used.
     
        By default, it does nothing.
     
        - Parameter controller: LoginController where the event is happening.
     */
    func didPassEmailValidation(controller: LoginController)
    
    /**
        Function called when any new email introduced is invalid,
        before setting the `emailTextFieldValid` property of the view used.
     
        By default, it does nothing.
     
        - Parameter controller: LoginController where the event is happening.
        - Parameter with: email validation errors.
     */
    func didFailEmailValidation(controller: LoginController, with errors: [String])
    
    /**
        Function called when any new password introduced is valid,
        before setting the `passwordTextFieldValid` property of the view used.
     
        By default, it does nothing.
     
        - Parameter controller: LoginController where the event is happening.
     */
    func didPassPasswordValidation(controller: LoginController)
    
    /**
        Function called when any new password introduced is valid,
        before setting the `passwordTextFieldValid` property of the view used.
     
        By default, it does nothing.
     
        - Parameter controller: LoginController where the event is happening.
        - Parameter with: password validation errors.
     */
    func didFailPasswordValidation(controller: LoginController, with errors: [String])
    
}

extension LoginControllerDelegate {
    
    public var shouldDisplayLoginErrorWithAlert: Bool { return true }
    
    public func willExecuteLogIn(controller: LoginController) {
        if let errorLabel = controller.loginView.logInErrorLabel {
            errorLabel.text = " "
        }
        let app = UIApplication.sharedApplication()
        app.networkActivityIndicatorVisible = true
    }
    
    public func didExecuteLogIn(controller: LoginController) {
        let app = UIApplication.sharedApplication()
        app.networkActivityIndicatorVisible = false
    }
    
    public func didLogIn(controller: LoginController, with error: SessionServiceError) {
        let app = UIApplication.sharedApplication()
        app.networkActivityIndicatorVisible = false
        if let errorLabel = controller.loginView.logInErrorLabel {
            errorLabel.text = error.message
        }
        if shouldDisplayLoginErrorWithAlert {
            let alert = UIAlertController(title: "login-error.alert.title".frameworkLocalized, message: error.message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "login-error.alert.close".frameworkLocalized, style: .Default, handler: nil))
            controller.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    public func didPassEmailValidation(controller: LoginController) { }
    
    public func didFailEmailValidation(controller: LoginController, with errors: [String]) { }
    
    public func didPassPasswordValidation(controller: LoginController) { }
    
    public func didFailPasswordValidation(controller: LoginController, with errors: [String]) { }
    
}

/**
    The default login controller delegate operates with the
    default behaviour of the LoginControllerDelegate protocol's methods.
*/
public final class DefaultLoginControllerDelegate: LoginControllerDelegate { }
