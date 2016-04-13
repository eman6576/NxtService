//
//  LoginViewController.swift
//  NxtService
//
//  Created by Emanuel  Guerrero on 3/28/16.
//  Copyright © 2016 Project Omicron. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicatorView: UIView!
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Listen for the event of when an account is created
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.accountWasCreated), name: NSNotificationCenterPostNotificationNames.ACCOUNT_CREATED, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopSpinning()
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case SegueIdentifiers.SIGNUP?:
            if let signUpViewController = segue.destinationViewController as? SignUpViewController {
                if let account = sender as? Account {
                    signUpViewController.account = account
                }
            }
        default:
            if let profileMenuViewController = segue.destinationViewController as? ProfileMenuViewController {
                if let account = sender as? Account {
                    profileMenuViewController.account = account
                }
            }
        }
    }
    
    // MARK: - Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginSignUpButtonTapped(sender: MaterialButton) {
        if let email = emailTextField.text where email != "", let password = passwordTextField.text where password != "" {
            
            // Start activity indicator animation
            startSpinning()
            
            DataService.dataService.REF_BASE.authUser(email, password: password, withCompletionBlock: { NSError, FAuthData in
                // Check if login successful
                if NSError != nil {
                    print(NSError.debugDescription)
                    
                    // Check error code
                    switch NSError.code {
                    case FirebaseErrorCodes.ACCOUNT_NONEXIST:
                        // Send user to sign up storyboard
                        self.goToSignUpStoryBoard(email, password: password)
                    case FirebaseErrorCodes.INVALID_EMAIL:
                        // Go back to the main thread to display the alert view controller
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stopSpinning()
                            self.showErrorAlert("Invalid email", message: "The email entered is not valid")
                        })
                    case FirebaseErrorCodes.TOO_MANY_REQUESTS:
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.stopSpinning()
                            self.showErrorAlert("Unknown error", message: "There was an unknown error logging in")
                        })
                    default:
                        // Go back to the main thread to display the alert view controller
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stopSpinning()
                            self.showErrorAlert("Invalid login", message: "Please check your email or password")
                        })
                    }
                    
                } else {
                    // Send user to profile menu controller
                    self.goToProfileMenuStoryBoard(email, password: password, accountID: FAuthData.uid)
                }
            })
        } else {
            showErrorAlert("Email and Password Required", message: "You must enter an email and a password")
        }
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Helper methods
    func showErrorAlert(title: String, message: String) {
        // Check if an alert controller is already being presented
        if self.presentedViewController == nil {
            createNewAlertViewController(title, message: message)
        } else {
            // The alert controller is already presented or there is another view controller being presented
            let thePresentedViewController: UIViewController? = self.presentedViewController as UIViewController?
            
            if thePresentedViewController != nil {
                
                // Check if the presented controller is an alert view controller
                if let presentedAlertViewController: UIAlertController = thePresentedViewController as? UIAlertController {
                    
                    // Do nothing since the alert controller is already on screen
                    print(presentedAlertViewController)
                } else {
                    // Another view controller presented, so use thePresentedViewController
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    thePresentedViewController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func createNewAlertViewController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func goToSignUpStoryBoard(email: String, password: String) {
        let account = Account(email: email, password: password, accountID: nil)
        performSegueWithIdentifier(SegueIdentifiers.SIGNUP, sender: account)
    }
    
    func goToProfileMenuStoryBoard(email: String, password: String, accountID: String) {
        let account = Account(email: email, password: password, accountID: accountID)
        performSegueWithIdentifier(SegueIdentifiers.PROFILE_MENU, sender: account)
    }
    
    func startSpinning() {
        indicatorView.hidden = false
        activityIndicatorView.startAnimating()
    }
    
    func stopSpinning() {
        indicatorView.hidden = true
        activityIndicatorView.stopAnimating()
    }
    
    func accountWasCreated() {
        showErrorAlert("Account created", message: "Please login to check out your profile")
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
