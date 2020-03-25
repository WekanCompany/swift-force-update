//
//  ViewController.swift
//  ForceUpdate
//
//  Created by Santhosh Kumar on 16/03/20.
//  Copyright © 2020 WeKanCode. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    /// AppDelegate
    static let appDelegate      =   UIApplication.shared.delegate as! AppDelegate
    /// App store url
    static let appStoreURL      =   "itms://itunes.apple.com/us/app/logistique/id1464647000?mt=8"
    /// App update title
    static let updateTitle      =   "App Update"
    /// App update message
    static let updateMessage    =   "A new version of Logistique Application is available, Please update new version."
}

class ViewController: UIViewController {

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Home"
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_ :)), name: Notification.Name("IS_VERSION_UPDATE"), object: nil)
        
        checkVersionUpdate()
    }
    
    // MARK: - Notification Observer
    
    /** Notification observer */
    @objc func notificationReceived(_ notification: Notification) {
        if notification.name.rawValue == "IS_VERSION_UPDATE" {
            //is force update available check
            checkVersionUpdate()
        }
    }
    
    /** Check version update */
    func checkVersionUpdate() {
        if let path = Bundle.main.path(forResource: "appUpdateStubs", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let response = jsonResult as? [String: Any] {
                    let responseInfo = response["data"]! as! [String: Any]
                    let isForceUpdate = responseInfo["is_force_update"] as! Bool
                    let appStoreVersion = responseInfo["version"] as! String
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    
                    if Double(version)! < Double(appStoreVersion)! {
                        self.showAlertForAppStore(!isForceUpdate)
                    }
                }
            } catch {
                print("error\(error.localizedDescription)")
            }
        }
    }
    
    /** Version update check
     - Parameter isShowCancel: To show/Hide cancel button on AlertController
     */
    func showAlertForAppStore(_ isShowCancel: Bool) {
        let myAlert = UIAlertController(title: Constants.updateTitle, message: Constants.updateMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            //Open appstore
            let urlStr = Constants.appStoreURL
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
        }
        
        if isShowCancel {
            let cancelAction = UIAlertAction(title: "Skip", style: UIAlertAction.Style.cancel) {
                (result : UIAlertAction) -> Void in
            }
            myAlert.addAction(cancelAction)
        }
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
}
