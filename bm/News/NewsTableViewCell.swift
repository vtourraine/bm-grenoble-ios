//
//  NewsTableViewCell.swift
//  bm
//
//  Created by Vincent Tourraine on 12/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import UIKit
import AlamofireImage

class NewsTableViewCell : UITableViewCell {
    @IBOutlet var title: UILabel?
    @IBOutlet var summary: UILabel?
    @IBOutlet var thumbnail: UIImageView?
    @IBOutlet var disclosure: UIImageView?
}

extension NewsTableViewCell {
    func configure(item: NewsItem) {
        title?.text = item.title
        summary?.text = item.summary

        thumbnail?.layer.cornerRadius = 8
        if let image = item.image {
            thumbnail?.af_setImage(withURL: image)
        }
        else {
            thumbnail?.image = nil
        }

        if #available(iOS 13.0, *) {
            disclosure?.image = UIImage(systemName: "chevron.right")
        }
    }
}
