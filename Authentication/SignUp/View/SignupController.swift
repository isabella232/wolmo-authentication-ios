//
//  SignupController.swift
//  Authentication
//
//  Created by Daniela Riesgo on 3/7/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import ReactiveCocoa

public final class SignupController: UIViewController {
    
    private let _viewModel: SignupViewModelType
    private let _signupViewFactory: () -> SignupViewType
    private let _delegate: SignupControllerDelegate
    private let _transitionDelegate: SignupControllerTransitionDelegate
    
    public lazy var signupView: SignupViewType = self._signupViewFactory()
    
    private let _notificationCenter: NSNotificationCenter = .defaultCenter()
    private var _disposable = CompositeDisposable()
    private let _keyboardDisplayed = MutableProperty(false)
    private let _activeTextField = MutableProperty<UITextField?>(.None)

    
    // Internal initializer, because if wanting to use the  default SignupController,
    // you should not override the `createSignupController` method, but all the others 
    // that provide the elements this controller uses. (That is to say,
    // `createSignupView`, `createSignupViewModel`, `createSignupControllerDelegate`)
    internal init(configuration: SignupControllerConfiguration) {
        _viewModel = configuration.viewModel
        _signupViewFactory = configuration.viewFactory
        _delegate = configuration.delegate
        _transitionDelegate = configuration.transitionDelegate
        super.init(nibName: nil, bundle: nil)
        addKeyboardObservers()
    }

    deinit {
        _disposable.dispose()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = signupView.view
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        signupView.render()
        bindViewModel()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecognizer)
    }
    
}

private extension SignupController {
    
    private func bindViewModel() {
        bindNameElements()
        bindEmailElements()
        bindPasswordElements()
        bindButtons()
        setTextfieldOrder()
        
        _viewModel.signUpExecuting.observeNext { [unowned self] executing in
            executing
                ? self._delegate.willExecuteSignUp(self)
                : self._delegate.didExecuteSignUp(self)
            self.signupView.signUpButtonPressed = executing
        }
        
        _viewModel.signUpErrors.observeNext { [unowned self] in self._delegate.didSignUp(self, with: $0) }
    }
    
    private func bindNameElements() {
        if let nameTextField = signupView.usernameTextField {
            _viewModel.name <~ nameTextField.rex_textSignal
            _viewModel.nameValidationErrors.signal.observeNext { [unowned self] errors in
                if errors.isEmpty {
                    self._delegate.didPassNameValidation(self)
                } else {
                    self._delegate.didFailNameValidation(self, with: errors)
                }
            }
            if let nameValidationMessageLabel = signupView.usernameValidationMessageLabel {
                nameValidationMessageLabel.rex_text <~ _viewModel.nameValidationErrors.signal.map { $0.first ?? " " }
            }
            nameTextField.delegate = self
        }
    }
    
    private func bindEmailElements() {
        _viewModel.email <~ signupView.emailTextField.rex_textSignal
        _viewModel.emailValidationErrors.signal.observeNext { [unowned self] errors in
            if errors.isEmpty {
                self._delegate.didPassEmailValidation(self)
            } else {
                self._delegate.didFailEmailValidation(self, with: errors)
            }
        }
        if let emailValidationMessageLabel = signupView.emailValidationMessageLabel {
            emailValidationMessageLabel.rex_text <~ _viewModel.emailValidationErrors.signal.map { $0.first ?? " " }
        }
        signupView.emailTextField.delegate = self
    }
    
    private func bindPasswordElements() {
        _viewModel.password <~ signupView.passwordTextField.rex_textSignal.on(next: { [unowned self] text in
            self.signupView.passwordVisibilityButton?.hidden = text.isEmpty
        })
        _viewModel.passwordValidationErrors.signal.observeNext { [unowned self] errors in
            if errors.isEmpty {
                self._delegate.didPassPasswordValidation(self)
            } else {
                self._delegate.didFailPasswordValidation(self, with: errors)
            }
        }
        if let passwordValidationMessageLabel = signupView.passwordValidationMessageLabel {
            passwordValidationMessageLabel.rex_text <~ _viewModel.passwordValidationErrors.signal.map { $0.first ?? " " }
        }
        if let passwordVisibilityButton = signupView.passwordVisibilityButton {
            passwordVisibilityButton.rex_pressed.value = _viewModel.togglePasswordVisibility
            _viewModel.passwordVisible.signal.observeNext { [unowned self] in self.signupView.passwordVisible = $0 }
        }
        signupView.passwordTextField.delegate = self
        bindPasswordConfirmationElements()
    }
    
    func bindPasswordConfirmationElements() {
        if let passwordConfirmationTextField = signupView.passwordConfirmTextField {
            _viewModel.passwordConfirmation <~ passwordConfirmationTextField.rex_textSignal.on(next: { [unowned self] text in
                self.signupView.passwordConfirmVisibilityButton?.hidden = text.isEmpty
            })
            _viewModel.passwordConfirmationValidationErrors.signal.observeNext { [unowned self] errors in
                if errors.isEmpty {
                    self._delegate.didPassPasswordConfirmationValidation(self)
                } else {
                    self._delegate.didFailPasswordConfirmationValidation(self, with: errors)
                }
            }
            if let passwordConfirmValidationMessageLabel = signupView.passwordConfirmValidationMessageLabel {
                passwordConfirmValidationMessageLabel.rex_text <~ _viewModel.passwordConfirmationValidationErrors.signal.map { $0.first ?? " " }
            }
            if let confirmPasswordVisibilityButton = signupView.passwordConfirmVisibilityButton {
                confirmPasswordVisibilityButton.rex_pressed.value = _viewModel.toggleConfirmPasswordVisibility
                _viewModel.confirmationPasswordVisible.signal.observeNext { [unowned self] in self.signupView.confirmationPasswordVisible = $0 }
            }
            passwordConfirmationTextField.delegate = self
        }
    }
    
    private func bindButtons() {
        signupView.signUpButton.rex_pressed.value = _viewModel.signUpCocoaAction
        signupView.signUpButton.rex_enabled.signal.observeNext { [unowned self] in self.signupView.signUpButtonEnabled = $0 }
        //TODO: signupView.termsAndServicesButton -> Presents the terms and services
        signupView.loginButton.setAction { [unowned self] _ in self._transitionDelegate.onLogin(self) }
    }
    
    private func setTextfieldOrder() {
        signupView.usernameTextField?.nextTextField = signupView.emailTextField
        signupView.emailTextField.nextTextField = signupView.passwordTextField
        signupView.passwordTextField.nextTextField = signupView.passwordConfirmTextField ?? signupView.usernameTextField ?? signupView.emailTextField
        signupView.passwordConfirmTextField?.nextTextField = signupView.usernameTextField ?? signupView.emailTextField
    }
    
    private var lastTextField: UITextField {
        return signupView.passwordConfirmTextField ?? signupView.passwordTextField
    }
    
}

extension SignupController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == lastTextField && _viewModel.signUpCocoaAction.enabled {
            textField.resignFirstResponder()
            _viewModel.signUpCocoaAction.execute("")
        } else {
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        if textField == signupView.usernameTextField {
            signupView.usernameTextFieldSelected = true
        } else if textField == signupView.emailTextField {
            signupView.emailTextFieldSelected = true
        } else if textField == signupView.passwordTextField {
            signupView.passwordTextFieldSelected = true
        } else {
            signupView.passwordConfirmationTextFieldSelected = true
        }
        _activeTextField.value = textField
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        if textField == signupView.usernameTextField {
            signupView.usernameTextFieldSelected = false
        } else if textField == signupView.emailTextField {
            signupView.emailTextFieldSelected = false
        } else if textField == signupView.passwordTextField {
            signupView.passwordTextFieldSelected = false
        } else {
            signupView.passwordConfirmationTextFieldSelected = false
        }
        _activeTextField.value = .None
    }
    
}

extension SignupController {

    private func addKeyboardObservers() {
        _disposable += _keyboardDisplayed <~ _notificationCenter
            .rac_notifications(UIKeyboardDidHideNotification)
            .map { _ in false }
        
        _disposable += _notificationCenter
            .rac_notifications(UIKeyboardWillShowNotification)
            .startWithNext { [unowned self] in self.keyboardWillShow($0) }
        
        _disposable += _notificationCenter
            .rac_notifications(UIKeyboardWillHideNotification)
            .startWithNext { [unowned self] _ in self.view.frame.origin.y = 0 }
    }
    
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if !_keyboardDisplayed.value {
                _keyboardDisplayed.value = true
                let keyboardOffset = keyboardSize.height
                let navBarOffset = navigationBarOffset()
                let textFieldOffset = calculateTextFieldOffsetToMoveFrame(keyboardOffset, navBarOffset: navBarOffset)
                if textFieldOffset > keyboardOffset {
                    self.view.frame.origin.y -= keyboardOffset
                } else {
                    self.view.frame.origin.y -= textFieldOffset
                }
                self.view.frame.origin.y += navBarOffset
            }
        }
    }
    
    private func navigationBarOffset() -> CGFloat {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat
        if navigationController?.navigationBarHidden ?? true {
            navBarHeight = 0
        } else {
            navBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        }
        return navBarHeight + statusBarHeight
    }
    
    private func calculateTextFieldOffsetToMoveFrame(keyboardOffset: CGFloat, navBarOffset: CGFloat) -> CGFloat {
        let topTextField = signupView.usernameTextField ?? signupView.emailTextField
        let top = topTextField.convertPoint(topTextField.frame.origin, toView: self.view).y - 10
        let bottomTextField = signupView.passwordConfirmTextField ?? signupView.passwordTextField
        let bottom = bottomTextField.convertPoint(bottomTextField.frame.origin, toView: self.view).y + bottomTextField.frame.size.height
        if (keyboardOffset + (bottom - top) + navBarOffset) <= self.view.frame.size.height {
            return top
        } else {
            return _activeTextField.value!.convertPoint(_activeTextField.value!.frame.origin, toView: self.view).y - 10
        }
    }
    
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        if _keyboardDisplayed.value {
            _keyboardDisplayed.value = false
            self.view.endEditing(true)
        }
    }
    
}