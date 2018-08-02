//
//  AlbumVC.swift
//  spotifyapp
//
//  Created by Sergio Giraldo on 21/10/17.
//  Copyright © 2017 Sergio Giraldo. All rights reserved.
//

import UIKit

class AlbumVC: UIViewController {

    //--------------------------------------
    // MARK: Outlets
    //--------------------------------------

    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var externalURLBtn: UIButton!

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------

    var album: [String : Any]?
    var EXTERNAL_LINK: URL?

    //--------------------------------------
    // MARK: Functions lifecycle
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor(red:0.11, green:0.73, blue:0.33, alpha:1.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false

        if let album = album {
            self.albumName.text = album["name"] as? String
            self.albumImage.kf.setImage(with: URL(string: album["image"] as! String))
            self.EXTERNAL_LINK = URL(string: (album["spt_external_url"] as? String)!)
        }
    }

    //--------------------------------------
    // MARK: Actions
    //--------------------------------------

    @IBAction func openExternalURL(_ sender: UIButton) {
        guard let url = self.EXTERNAL_LINK else {
            return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
