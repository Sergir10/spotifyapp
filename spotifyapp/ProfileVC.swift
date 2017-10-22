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

class ProfileVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

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
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var popularityTitle: UILabel!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumTable: UITableView!


    //--------------------------------------
    // MARK: Functions lifeciclye
    //--------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        artistSearchBar.delegate = self
        albumTable.delegate = self
        albumTable.dataSource = self

        self.followersTitle.isHidden = true
        self.popularityTitle.isHidden = true

        self.touchGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(touchGesture)
        getSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        albumTitle.layer.masksToBounds = true
        albumTitle.layer.cornerRadius = 10
        albumTable.estimatedRowHeight = 100
        albumTable.rowHeight = UITableViewAutomaticDimension
    }

    //--------------------------------------
    // MARK: Functions Delegates
    //--------------------------------------

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            getArtistSPT(artistName: searchBarText)
            searchBar.resignFirstResponder()
        }
    }

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

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(touchGesture)
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

    //--------------------------------------
    // MARK: Functions
    //--------------------------------------

    func getSession() {
        let sessionObj: AnyObject = (UserDefaults.standard.object(forKey: "spotifySession") as AnyObject?)!
        let sessionDataObj = sessionObj as! Data
        self.session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
    }

    func getArtistSPT(artistName: String) {
        remoteServices.getArtist(name: artistName, session: self.session, completionHandler: { artist in
            if let artist = artist {
                let artistImageURL = URL(string: artist["image"]!)

                self.getAlbumsSPT(artistID: artist["id"]!)
                self.followersTitle.isHidden = false
                self.popularityTitle.isHidden = false
                self.artistName.text = artist["name"]
                self.artistFollowers.text = artist["followers"]
                self.artistPopularity.text = artist["popularity"]
                self.artistImage.kf.setImage(with: artistImageURL!)
                self.artistSearchBar.text = ""
                self.hideKeyboard()
            } else {
                let artistNotFoundAlert = UIAlertController(title: "ERROR", message: "Artista no encontrado!", preferredStyle: UIAlertControllerStyle.alert)
                artistNotFoundAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(artistNotFoundAlert, animated: true, completion: nil)
                self.artistSearchBar.text = ""
                print("No se ha encontrado el artista buscado.")
            }
        })
    }

    func getAlbumsSPT(artistID: String) {
        remoteServices.getAlbum(id: artistID, session: self.session, completionHandler: { albums in
            if let albums = albums {
                self.albumsInfo = albums
                self.albumTable.reloadData()
            } else {
                let artistNotFoundAlert = UIAlertController(title: "ATENCIÓN", message: "No hay albumes para mostrar", preferredStyle: UIAlertControllerStyle.alert)
                artistNotFoundAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(artistNotFoundAlert, animated: true, completion: nil)
                print("El artista no tiene albumes registrados.")
            }
        })
    }

    func hideKeyboard() {
        self.artistSearchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(self.touchGesture)
    }
}
