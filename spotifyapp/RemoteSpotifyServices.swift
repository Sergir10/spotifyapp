//
//  RemoteSpotifyServices.swift
//  spotifyapp
//
//  Created by Sergio Giraldo on 20/10/17.
//  Copyright © 2017 Sergio Giraldo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RemoteSpotifyServices {


    func getArtist(name: String, session: SPTSession, completionHandler: @escaping ([String : String]?) -> Void) {

        let SPOTIFY_SEARCH_URL = URL(string: "https://api.spotify.com/v1/search")
        let headers: HTTPHeaders = ["Authorization": "\(session.tokenType!) \(session.accessToken!)",
            "Accept": "application/json"]
        let parameters: Parameters = ["q": name, "type": "artist"]

        Alamofire.request(SPOTIFY_SEARCH_URL!, parameters: parameters, headers: headers).validate().responseJSON() { resp in
            switch resp.result {
            case .success:
                if let artistsData = resp.result.value {
                    let artistsJson = JSON(artistsData)
                    var artist = [String : String]()

                    let artistsObject = artistsJson["artists"]["items"][0].dictionaryValue
                    let total = artistsJson["artists"]["total"].int
                    if total != 0 {
                        artist["name"] = artistsObject["name"]?.stringValue
                        artist["followers"] = artistsObject["followers"]?["total"].stringValue
                        artist["popularity"] = artistsObject["popularity"]?.stringValue
                        artist["image"] = artistsObject["images"]?[0]["url"].stringValue
                        artist["id"] = artistsObject["id"]?.stringValue
                        artist["total"] = artistsObject["total"]?.stringValue
                        completionHandler(artist)
                    } else {
                        completionHandler(nil)
                    }
                }
            case .failure(let err):
                print(err)
                completionHandler(nil)
            }
        }
    }

    func getAlbum(id: String, session: SPTSession, completionHandler: @escaping ([[String : Any]]?) -> Void) {

        let SPOTIFY_ALBUMS_URL = URL(string: "https://api.spotify.com/v1/artists/\(id)/albums")
        let headers: HTTPHeaders = ["Authorization": "\(session.tokenType!) \(session.accessToken!)",
            "Accept": "application/json"]
        let parameters: Parameters = ["album_type": "album"]

        Alamofire.request(SPOTIFY_ALBUMS_URL!, parameters: parameters, headers: headers).validate().responseJSON() { resp in
            switch resp.result {
            case .success:
                if let albumsData = resp.result.value {
                    let albumsJSON = JSON(albumsData)
                    var albumsArray = [[String : Any]]()

                    let items = albumsJSON["items"].arrayValue
                    let total = albumsJSON["total"].int
                    if total != 0 {
                        for item in items {
                            var album = [String : Any]()
                            let avaibleMarkets = item["available_markets"].arrayValue
                            if (avaibleMarkets.count < 5) {
                                var countries = ""
                                for country in avaibleMarkets {
                                    countries += "\(country.rawString()!)-"
                                }
                                countries = String(countries[..<countries.index(countries.endIndex, offsetBy: -1)])
                                album["avaibleMarkets"] = countries
                            }
                            album["image"] = item["images"][0]["url"].stringValue
                            album["name"] = item["name"].stringValue
                            album["external_url_spotify"] = item["external_urls"]["spotify"].stringValue
                            albumsArray.append(album)
                        }
                        completionHandler(albumsArray)
                    } else {
                        completionHandler(nil)
                    }
                }
            case .failure(let err):
                print(err)
                completionHandler(nil)
            }
        }
    }
}































