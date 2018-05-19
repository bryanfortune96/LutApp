//
//  CustomInfoWindowUIView.swift
//  Lut
//

import UIKit
import MarqueeLabel
import Cosmos

class CustomInfoWindowUIView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var radiusLb: UILabel!
    @IBOutlet weak var levelLb: UILabel!
    @IBOutlet weak var nextLevelLb: UILabel!
    @IBOutlet weak var pointLb: UILabel!
    @IBOutlet weak var nameLb: MarqueeLabel!
    @IBOutlet weak var userLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var reasonLb: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    var contentView: CustomInfoWindowUIView!
    var trafficInfo: EventDetailsObject?
    
    init(frame: CGRect, trafficInfo: EventDetailsObject){
        super.init(frame: frame)
        self.trafficInfo = trafficInfo
        setupContentView()
        setupObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupContentView() {
        contentView = Bundle.main.loadNibNamed("CustomInfoWindowUIView", owner: self, options: nil)?.first as! CustomInfoWindowUIView
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: (trafficInfo?.updatedAt)!)
        let time = Helpers.timeAgoSinceDate(date: date! as NSDate, numericDates: false)
        let array = Helpers.getReasons(reasons: (trafficInfo?.reasons)!)
        var reasonsText = ""
        if array.count != 0 {
            for i in 0...array.count - 1
            {
                if i == array.count - 1
                {
                    reasonsText.append("\(array[i])")
                }
                else
                {
                    reasonsText.append("\(array[i]) ,")
                }
            }
        }
        let authorText = trafficInfo?.author?.nickname != ""
            ? (trafficInfo?.author?.nickname)! : (trafficInfo?.author?.email)!
        
        contentView.starRatingView.settings.starSize = 30.0
        contentView.reasonLb.text = "Causes: \(reasonsText)"
        contentView.radiusLb.text = "\(String(describing: (trafficInfo?.radius)!))m"
        contentView.levelLb.text = "\(String(describing: (trafficInfo?.level)!))cm"
        contentView.nextLevelLb.text = "\((trafficInfo?.nextLevel)!/60)cm"
        contentView.dateLb.text = "\(time)"
        contentView.userLb.text = "updated by \(authorText)"
        contentView.nameLb.text = "\((trafficInfo?.name)!)                 "
        contentView.pointLb.text = "\(String(describing: roundPoint(point: (trafficInfo?.points?.points)!)))/5"
        if !(trafficInfo?.imagePaths?.isEmpty)! {
            contentView.imageView.sd_setImage(with: NSURL(string: (trafficInfo?.imagePaths![0])!) as URL?, placeholderImage: #imageLiteral(resourceName: "user"), options: [.refreshCached])
        }
        contentView.imageView.layer.cornerRadius = 20
        contentView.imageView.clipsToBounds = true
        showUnvotedStars()
        if (trafficInfo?.alreadyVoted!)! {
            showVotedStars()
            contentView.starRatingView.rating = trafficInfo!.votedScore!
        }
        
        contentView.starRatingView.settings.filledBorderColor = UIColor.orange
        contentView.starRatingView.settings.filledBorderWidth = 2.5
        contentView.starRatingView.didFinishTouchingCosmos = didFinishTouchingRatingView
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePointAfterRating(_:)), name: NSNotification.Name("UpdateScoreAfterRating"), object: nil)
    }
    
    private func didFinishTouchingRatingView(_ rating: Double) {
        print(rating/5)
        NotificationCenter.default.post(name: NSNotification.Name("VoteTrafficInfo"), object: nil, userInfo: ["rating": rating/5, "eventID": (trafficInfo?.id)!])
    }
        
    private func checkIfEventBelongsToCurrentUser(authorId: String) -> Bool  {
        let userId = UserDefaults.standard.string(forKey: "UserID")
        if userId == authorId {
            return true
        }
        return false
    }
    
    @objc private func updatePointAfterRating(_ notification: NSNotification) {
        let score = notification.userInfo!["score"] as! Double
        if !checkIfEventBelongsToCurrentUser(authorId: (trafficInfo?.author?.id)!) {
            showVotedStars()
            contentView.pointLb.text = "\(roundPoint(point: score))/5"
        } else {
            showUnvotedStars()
        }
    }
    
    private func showVotedStars() {
        contentView.starRatingView.settings.filledColor = UIColor.orange
    }
    
    private func showUnvotedStars() {
        contentView.starRatingView.rating = 0.0
    }
    
    private func roundPoint(point: Double) -> Double {
        return Double(round(100*point)/100)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
