//
//  ViewController.swift
//  spotifyapp
//
//  Created by Sergio Giraldo on 20/10/17.
//  Copyright © 2017 Sergio Giraldo. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate{

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------

    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?

    //--------------------------------------
    // MARK: Outlet
    //--------------------------------------

    @IBOutlet weak var loginButton: UIButton!


    //--------------------------------------
    // MARK: Functions
    //--------------------------------------

    override func loadView() {
        super.loadView()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.afterLogin), name: NSNotification.Name(rawValue: "LogginSuccefull"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        settings()
    }

    func settings(){
        let spotifyClientID = "03741125e45a4a24b307d946159e62ea"
        let redirectURLAfterLogin = "spotifyapp://returnafterlogin"

        auth.clientID = spotifyClientID
        auth.redirectURL = URL(string: redirectURLAfterLogin)
        auth.requestedScopes = []
        loginUrl = auth.spotifyWebAuthenticationURL()
        checkSession()
    }

    func checkSession() {
        if let sessionObj: AnyObject = (UserDefaults.standard.object(forKey: "spotifySession") as AnyObject?) {
            let sessionDataObj = sessionObj as! Data
            self.session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession

            if (self.session.isValid()) {
                afterLogin()
            } else {
                self.auth.renewSession(self.session, callback: {
                    err, session in
                    self.session = session
                })
            }
        }
    }

    @objc func afterLogin() {
        if let _: AnyObject = UserDefaults.standard.object(forKey: "spotifySession") as AnyObject? {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC: UIViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileVC")
            let navController = UINavigationController(rootViewController: nextVC)
            self.present(navController, animated:true, completion:nil)
        }
    }

    //--------------------------------------
    // MARK: Actions
    //--------------------------------------

    @IBAction func loginSpotify(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: {
                (success) in
                if (self.auth.canHandle(self.auth.redirectURL)){

                }
            })
        } else {
            UIApplication.shared.openURL(loginUrl!)
        }
    }
    
    
}

