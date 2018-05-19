//
//  BaseViewTableViewCell.swift
//  Banana
//

import UIKit

class BaseViewTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(title: String,image: UIImage)
    {
        titleLb.text = title
        imageView?.image = image
    }
    
}
