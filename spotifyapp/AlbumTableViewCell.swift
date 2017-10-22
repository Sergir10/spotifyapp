//
//  AlbumTableViewCell.swift
//  spotifyapp
//
//  Created by Sergio Giraldo on 21/10/17.
//  Copyright © 2017 Sergio Giraldo. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {


    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var countriesAvaible: UILabel!
    @IBOutlet weak var countriesAvaiblesDescription: UILabel!
    @IBOutlet weak var albumImage: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
