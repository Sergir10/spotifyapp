//
//  ProfileVC.swift
//  spotifyapp
//
//  Created by Sergio Giraldo on 20/10/17.
//  Copyright © 2017 Sergio Giraldo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ProfileVC: UIViewController {

    let remoteServices = RemoteSpotifyServices()

    //--------------------------------------
    // MARK: Variables
    //--------------------------------------

    var session: SPTSession!
    var touchGesture: UIGestureRecognizer!
    var albumsInfo: [[String : Any]] = []

    //--------------------------------------
    // MARK: Outlet
    //--------------------------------------

    @IBOutlet weak var artistSearchBar: UISearchBar!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistFollowers: UILabel!
    @IBOutlet weak var artistPopularity: UILabel!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumTable: UITableView!
    @IBOutlet weak var artistView: UIView!
    @IBOutlet var searchView: UIView!


    //--------------------------------------
    // MARK: Functions lifeciclye
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        settingView()

        artistSearchBar.delegate = self
        albumTable.delegate = self
        albumTable.dataSource = self

        self.touchGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(touchGesture)

        getSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }

    //--------------------------------------
    // MARK: Functions
    //--------------------------------------

        
    /// <#Description#>
    func settingView() {

        searchView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        view.addSubview(searchView)

        albumTitle.layer.masksToBounds = true
        albumTitle.layer.cornerRadius = 10
        albumTable.estimatedRowHeight = 100
        albumTable.rowHeight = UITableViewAutomaticDimension
    }

    
    /// <#Description#>
    func getSession() {
        let sessionObj: AnyObject = (UserDefaults.standard.object(forKey: "spotifySession") as AnyObject?)!
        let sessionDataObj = sessionObj as! Data
        self.session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
    }


    /// <#Description#>
    ///
    /// - Parameter artistName: <#artistName description#>
    func getArtistSPT(artistName: String) {
        remoteServices.getArtist(name: artistName, session: self.session, completionHandler: { art in

            guard let artist = art else {
                self.launchAlert(alertToShow: 1)

                self.artistView.isHidden = true
                self.albumTitle.isHidden = true
                self.albumTable.isHidden = true
                self.view.addSubview(self.searchView)

                return
            }

            self.artistSearchBar.text = ""
            self.getAlbumsSPT(artistID: artist["id"]!)
            self.parseArtist(artist: artist)
            self.hideKeyboard()
        })
    }


    /// <#Description#>
    ///
    /// - Parameter artistID: <#artistID description#>
    func getAlbumsSPT(artistID: String) {
        remoteServices.getAlbum(id: artistID, session: self.session, completionHandler: { albums in
            guard let albumes = albums else {
                self.launchAlert(alertToShow: 2)
                self.albumTitle.isHidden = true
                self.albumTable.isHidden = true
                return
            }

            self.albumTable.isHidden = false
            self.albumTable.isHidden = false
            self.albumsInfo = albumes
            self.albumTable.reloadData()
        })
    }


    /// <#Description#>
    ///
    /// - Parameter artist: <#artist description#>
    func parseArtist(artist : [String:String]) {

        if let vs = view.viewWithTag(10) {
            vs.removeFromSuperview()
        }

        artistView.isHidden = false

        artistName.text = artist["name"]
        artistFollowers.text = artist["followers"]
        artistPopularity.text = artist["popularity"]
        artistImage.kf.setImage(with: URL(string: artist["image"]!))
    }


    /// <#Description#>
    func launchAlert(alertToShow: Int) {
        let alert = UIAlertController(title: "¡Atención!", message: "", preferredStyle: UIAlertControllerStyle.alert)

        if alertToShow == 1 {
            alert.message = "Artista no encontrado."
        } else {
            alert.message = "El artista no tiene álbumes"
        }

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.artistSearchBar.text = ""
    }

    @objc func hideKeyboard() {
        self.artistSearchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(self.touchGesture)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailAlbum" {
            if let indexAlbumSelected = self.albumTable.indexPathForSelectedRow {
                var albumSelected = self.albumsInfo[indexAlbumSelected.row]
                albumSelected["spt_external_url"] = self.albumsInfo[indexAlbumSelected.row]["external_url_spotify"]
                let albumVC = segue.destination as! AlbumVC
                albumVC.album = albumSelected
            }
        }
    }
}

//--------------------------------------
// MARK: UITableView DELEGATES
//--------------------------------------

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumsInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumTable.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! AlbumTableViewCell

        let album = self.albumsInfo[indexPath.row]
        cell.albumName.text = album["name"] as? String
        cell.albumImage.kf.setImage(with: URL(string: album["image"] as! String))
        if let avaibleCountries = album["avaibleMarkets"] as? String {
            cell.countriesAvaiblesDescription.text = avaibleCountries
        } else {
            cell.countriesAvaiblesDescription.text = "Más de 5."
        }
        return cell
    }

}

//--------------------------------------
// MARK: UISearchBar DELEGATES
//--------------------------------------

extension ProfileVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            getArtistSPT(artistName: searchBarText)
            searchBar.resignFirstResponder()
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(touchGesture)
    }
}
