//
//  RankViewTableViewCell.swift
//  Banana
//


import UIKit

class RankViewTableViewCell: UITableViewCell {

    @IBOutlet weak var positionLb: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var usrNameLb: UILabel!
    @IBOutlet weak var pointsRankLb: UILabel!
    @IBOutlet weak var rankImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 60.0/2
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(usrInfo: UsersObject,position: Int,choosingOption: Int)
    {
        positionLb.text = String(position)
//        if (usrInfo.avatarImgPath?.isEmpty)! {
//            avatarImgView.image = #imageLiteral(resourceName: "user")
//        } else {
//            
//        }
        avatarImgView.sd_setImage(with: URL(string: usrInfo.avatarImgPath!), placeholderImage: #imageLiteral(resourceName: "user"), options: [.refreshCached])
        if usrInfo.point != nil {
            let point = choosingOption == 0 ? usrInfo.point : usrInfo.queryPoint
            pointsRankLb.text = "\((point)!) points | \(DataMgr.shared.levels[usrInfo.level!])"
        }
        
        if usrInfo.nickname == ""
        {
            usrNameLb.text = usrInfo.email
        }
        else{
            usrNameLb.text = usrInfo.nickname

        }
        
    }
    
}
