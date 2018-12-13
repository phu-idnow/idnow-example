//
//  ViewController.swift
//  DemoIDNow
//
//  Created by phu nguyen on 12/13/18.
//  Copyright © 2018 anonymous. All rights reserved.
//

import UIKit
import IDnowSDK

class ViewController: UIViewController {
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var appName: UILabel!
    
    fileprivate let settings : IDnowSettings
    fileprivate let idnowController : IDnowController
    
    required init?(coder aDecoder: NSCoder)
    {
        settings = IDnowSettings(companyID: "ihrebank")
        settings.showIdentTokenOnCheckScreen = true
        settings.showErrorSuccessScreen      = true        
        
        idnowController = IDnowController(settings: settings)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tokenTextField.text = "DEV-CWJXV"
        if let name = Bundle.main.infoDictionary!["CFBundleName"] as? String {
            appName.text = name
        }
    }

    @IBAction func confirmToken(_ sender: UIButton) {
        settings.transactionToken = tokenTextField.text!
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        idnowController
            .initialize {[weak self] (success, error, canceledByUser) -> Void in
            self?.hideNetworkIndicator()
            print("Requested session with success: \(success), error: \(error.debugDescription), canceled by user: \(canceledByUser)")
            
            // Do nothing if self is no longer there
            guard let strongSelf = self else { return }
            
            // Success
            if success == true
            {
                strongSelf.idnowController
                    .startIdentification(from: strongSelf,
                                         withCompletionBlock: { (success, error, canceledByUser) -> Void in
                    self?.hideNetworkIndicator()
                    print("Identification finished with success: \(success), error: \(error.debugDescription), canceled by user: \(canceledByUser)")
                })
                
                return
            }
            
            guard let _error = error else
            {
                return
            }
            
            // Failure
            switch _error._code
            {
            case IDnowError.cameraAccessNotGranted.rawValue:
                print("CAMERA_ACCESS_DENIED_ALERT_TITLE %@",
                      NSLocalizedString("CAMERA_ACCESS_DENIED_ALERT_TITLE", comment: ""));
            case IDnowError.microphoneAccessNotGranted.rawValue:
                print("MICROPHONE_ACCESS_DENIED_ALERT_TITLE %@",
                      NSLocalizedString("MICROPHONE_ACCESS_DENIED_ALERT_TITLE", comment: ""));
            default:
                print("Have something wrong");
            }
        }
        
    }
    
    private func hideNetworkIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
}

