//
//  TableViewCell.swift
//  GreenTest
//
//  Created by djm on 2024/3/7.
//

import UIKit
import Kingfisher

class TableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func setData(with model: MusicModel) {
        /// 封面
        iconImageView.kf.setImage(with: URL(string: model.artworkUrl60 ?? ""))
        /// 艺术家姓名
        nameLabel.text = model.artistName ?? ""
        /// 曲目名称 + 发布日期
        descLabel.text = (model.trackName ?? "") + " " + (model.releaseDate ?? "")
        /// 价格
        priceLabel.text = "$" + String(model.trackPrice ?? 0.0)
    }
}
