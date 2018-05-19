//
//  HomeViewController.swift
//  Banana
//


import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SDWebImage

let CIRCLE_ALPHA: CGFloat = 0.4

class HomeViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var distanceLb: UILabel!
    
    @IBOutlet weak var submitView2Constraint: NSLayoutConstraint!
    @IBOutlet weak var submitViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var densBoardConstraint: NSLayoutConstraint!
    @IBOutlet weak var gpsButtConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButtConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceLbConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitText: UILabel!
    @IBOutlet weak var radiusLb: UILabel!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var submitView2: UIView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var searchImgView: UIImageView!
    @IBOutlet weak var placeLb: UILabel!
    @IBOutlet weak var removePlaceButt: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var topAlertView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var blackView2: UIView!
    @IBOutlet weak var rankImgView: UIImageView!
    @IBOutlet weak var rankImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var pointsRankLb: UILabel!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    var userID = ""
    var token = ""
    var userName = ""
    var locationButt: UIButton!
    var userLongtitude = 0.0
    var userLatitude = 0.0
    var placeLongtitude = 0.0
    var placeLatitude = 0.0
    var radius: Int?
    var placeTitle = ""
    var polylineArrays: [GMSPolyline] = []
    var circleArray: [GMSCircle] = []
    var markerArray: [GMSMarker] = []
    var placeLocMarker: GMSMarker?
    var userLocMarker: GMSMarker?
    var userLocView: UIImageView?
    var placeLocView: UIImageView?
    var upvoteResponse: UpvoteEventResponse? {
        didSet {
            self.hideLoading()
            if (upvoteResponse?.success)! {
                NotificationCenter.default.post(name: NSNotification.Name("UpdateScoreAfterRating"), object: nil, userInfo: ["score": (upvoteResponse?.data?.point?.points)!])
                let alert = UIAlertController(title: "Message", message: "Thank you for your rating.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("UpdateScoreAfterRating"), object: nil, userInfo: ["score": -1.0])
                let alert = UIAlertController(title: "Warning!", message: upvoteResponse?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    var userInfo: UsersObject?
    {
        didSet {
            if userInfo?.avatarImgPath != "" {
                self.avatarImgView.sd_setImage(with: URL(string: (userInfo?.avatarImgPath)!), placeholderImage: #imageLiteral(resourceName: "user"), options: [.refreshCached])
            }
            if userInfo?.point != nil {
                self.pointsRankLb.text = "\(String(describing: (userInfo?.point)!)) points | \(DataMgr.shared.levels[(userInfo?.level)!])"
            }
            switch (userInfo?.level)! {
            case 0:
                rankImgView.image = UIImage(named: "1star_icon")
                rankImageViewWidth.constant = 41
            case 1:
                rankImgView.image = UIImage(named: "2star_icon")
                rankImageViewWidth.constant = 82
            case 2:
                rankImgView.image = UIImage(named: "3star_icon")
                rankImageViewWidth.constant = 123
            case 3:
                rankImgView.image = UIImage(named: "4star_icon")
                rankImageViewWidth.constant = 163
            case 4:
                rankImgView.image = UIImage(named: "5star_icon")
                
            default:
                break
            }
        }
    }
    var userResponse: GetUserResponse?
    {
        didSet{
            if (userResponse?.success)!
            {
                self.userInfo = (userResponse?.data)!
            }
            else{
                let alert = UIAlertController(title: "Warning!", message: userResponse?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    var getClusterResponse: ClusterListResponse?
    {
        didSet{
            self.hideLoading()
            if (getClusterResponse?.success)!
            {
                filterDataByFavorite(response: getClusterResponse!)
            }
            else{
                let alert = UIAlertController(title: "Warning!", message: getClusterResponse?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    var traffics: [ClusterDetailsObject] = []
    {
        didSet{
            clearData()
            updateTraffic()
        }
    }
    var alreadyGotLocation = false
    var stageOfSubmission = 0
    let locationManager = CLLocationManager()
    var settingIconList = [#imageLiteral(resourceName: "noti_icon"),#imageLiteral(resourceName: "favorite_icon"),#imageLiteral(resourceName: "idea_icon"),#imageLiteral(resourceName: "reward_icon"),#imageLiteral(resourceName: "help_icon")]
    var settingTitleList =  ["Notification","Favorite","Feedback","Rewards","Help"]
    var sourceMarker: GMSMarker?
    var destMarker: GMSMarker?
    var sourceCoordinate: CLLocationCoordinate2D?
    var submitDistance = ""
    var submitPlaceName = "" {
        didSet {
            if submitPlaceName != "" {
                self.drawCircle(source: self.sourceCoordinate!, radius: self.radius!, level: -1,eventID: "-1")
                self.distanceLbConstraint.constant = 38
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    var userChangedLocation = false
    var directionLine: GMSPolyline?
    var demoCircle: GMSCircle?

    override func viewDidLoad() {
        super.viewDidLoad()
        //checkLogin()
        loadDB()
        setupView()
        setupMap()
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(afterSubmit), name: NSNotification.Name("CloseSubmitView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(upVoteEvent(_:)), name: NSNotification.Name("VoteTrafficInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(afterLogin), name: NSNotification.Name("LoginDismissed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadDB), name: NSNotification.Name("CloseDetailScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadDB), name: NSNotification.Name("AfterUpdateAvatar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadDB), name: NSNotification.Name("AfterUpdateFavorite"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForGPS()
        if UserDefaults.standard.string(forKey: "UserName") == ""
        {
            userNameLb.text = UserDefaults.standard.string(forKey: "Email")
        }
        else
        {
            userNameLb.text = UserDefaults.standard.string(forKey: "UserName")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func appWillEnterForeground() {
        checkForGPS()
    }
    
    func filterDataByFavorite(response: ClusterListResponse) {
        var filterTraffics: [ClusterDetailsObject] = []
        let allTraffics = (getClusterResponse?.data)!
        let def = Int32(UserDefaults.standard.integer(forKey: "BitMask"))
        DataMgr.shared.updateDistrict(districtsBitMask: def)
        let districts = DataMgr.shared.getDistricts()
        if districts[0].isFavorite {
            traffics = allTraffics
        } else {
            for cluster in allTraffics {
                for district in districts {
                    if getDistrict(placeName: cluster.eventList![0].name!) == district.id && district.isFavorite {
                        filterTraffics.append(cluster)
                    }
                }
            }
            traffics = filterTraffics
        }
    }
    
    func getDistrict(placeName: String) -> Int
    {
        let districts = DataMgr.shared.districts
        var district: Int = 0
        for x in districts
        {
            let title = "\(x.title),"
            if placeName.range(of: title) != nil
            {
                district = x.id!
            }
        }
        
        return district
    }
    
    func moveToPlace()
    {
        let zoomLevel = stageOfSubmission != 0 ? 17.0 : 13.0
        placeLb.text = placeTitle
        searchImgView.isHidden = true
        removePlaceButt.isHidden = false
        placeLocMarker?.map = nil
        let camera = GMSCameraPosition.camera(withLatitude: placeLatitude,
                                              longitude: placeLongtitude,
                                              zoom: Float(zoomLevel))
  
        mapView.camera = camera
        
        let position = CLLocationCoordinate2D(latitude: placeLatitude, longitude: placeLongtitude)
        let marker = GMSMarker(position: position)
        marker.title = placeTitle
        marker.map = mapView
        if stageOfSubmission != 0
        {
            sourceMarker = marker
            sourceCoordinate = CLLocationCoordinate2D(latitude: placeLatitude, longitude: placeLongtitude)
        }
        else{
            placeLocMarker = marker
            
        }
    }
    
    func loadDB()
    {
        userID = UserDefaults.standard.string(forKey: "UserID")!
        token = UserDefaults.standard.string(forKey: "Token")!
        
        if userID != ""
        {
            self.showLoading()
            ServiceHelpers.getEventList(userID: userID){ (response) in
                self.getClusterResponse = response
            }
            ServiceHelpers.getUser(userID: userID, token: token){(response) in
                self.userResponse = response
            }
        }
        else {
            ServiceHelpers.getEventList(userID: "-1") { (response) in
                self.getClusterResponse = response
            }
        }
    }

    func checkForGPS()
    {
        alertView.isHidden = true
        if !CLLocationManager.locationServicesEnabled()
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.blackView2.isHidden = false
                self.alertView.isHidden = false
            })
        }
        else{
            alertView.isHidden = true
            blackView2.isHidden = true
            getUserLocation()
        }
        
    }
    
    func setupView()
    {
        //add rounded corner and tap gesture to submit views
        submitView.layer.cornerRadius = 10
        submitView.layer.shadowOpacity = 0.6
        submitView.layer.shadowRadius = 10
        submitView2.layer.cornerRadius = 10
        submitView2.layer.shadowOpacity = 0.6
        submitView2.layer.shadowRadius = 10
        
        //add rounded corner and tap gesture to search view
        searchView.layer.cornerRadius = 10
        searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSearch)))
        
        //add shadow to alert view
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOffset = CGSize(width: 3, height: 3)
        alertView.layer.shadowOpacity = 0.7
        alertView.layer.shadowRadius = 4
        
        //add round shape to alert view
        alertView.layer.cornerRadius = 10
        topAlertView.layer.cornerRadius = 10
        
        //add shadow to menu view
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 3, height: 3)
        menuView.layer.shadowOpacity = 0.7
        menuView.layer.shadowRadius = 4
        
        //change avatar view into rounded shape
        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 75.0/2
        avatarImgView.layer.shadowOpacity = 0.5
        avatarImgView.layer.shadowRadius = 5
        avatarImgView.isUserInteractionEnabled = true
        avatarImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAccount)))
        
        //setup Table View
        settingTableView.delegate  = self
        settingTableView.dataSource = self
        settingTableView.register(UINib(nibName:"HomeViewTableViewCell",bundle:nil), forCellReuseIdentifier: "HomeViewTableViewCell")
        settingTableView.isScrollEnabled = false
        
        blackView.isHidden = true
        leadingConstraint.constant = -UIScreen.main.bounds.width
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
        
        removePlaceButt.isHidden = true
        distanceLb.isHidden = true
        
        //setup slider UIView
        radiusSlider.isContinuous = true
        radiusSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        radius = 50
        radiusSlider.setValue(0.25, animated: false)
        radiusLb.text = "\(radius!) m"
        
        self.gpsButtConstraint.constant = -50
        self.submitButtConstraint.constant = -50
        self.densBoardConstraint.constant = -150
    }
    
    func sliderValueChanged()
    {
        radius = Int(Double(radiusSlider.value) * 200)
        radiusLb.text = "\(String(describing: radius!)) m"
    }
    
    func openAccount()
    {
        let vc = AccountViewController()
        vc.userInfo = userInfo
        self.present(vc, animated: true, completion: nil)
    }
    
    func openSearch()
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    
    }
    
    @objc func upVoteEvent(_ notification: NSNotification) {
        let param = ["userId": userID, "token": token, "eventId": (notification.userInfo!["eventID"])!, "score": (notification.userInfo!["rating"])!]
        self.showLoading()
        ServiceHelpers.upvoteEvent(param: param){(response) in
            self.upvoteResponse = response
        }
    }
    
    @objc func closeMenu() {
        self.blackView.isHidden = true
        self.leadingConstraint.constant = -UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func setupMap()
    {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.zoomGestures = true
        
    }
    
    func clearData()
    {
        //delete the former traffic polylines to redraw new refreshed lines
        for x in polylineArrays
        {
            x.map = nil
        }
        mapView.clear()
    }
    
    func updateTraffic()
    {
        //mapView.clear()
        for x in traffics
        {
            for y in x.eventList! {
                let source = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(y.startLatitude!), longitude: CLLocationDegrees(y.startLongtitude!))
                //drawPolylineRoute(from: source, to: dest, density: x.density!)
                if source.latitude < source.longitude {
                    drawCircle(source: source, radius: y.radius!, level: x.level!,eventID: y.id!)
                }
            }
        }
    }
    
    func drawIcon(location: CLLocationCoordinate2D,kind: Int)
    {
        var icon = UIImage()
        switch kind {
        case 0:
            icon = #imageLiteral(resourceName: "rain_icon")
        case 1:
            icon = #imageLiteral(resourceName: "accident_icon")
        case 2:
            icon = #imageLiteral(resourceName: "flood_icon")
        default:
            break
        }
        
        let icon_resized = changeImageSize(image: icon, scaledToSize: CGSize(width: 26, height: 26))
        let markerView = UIImageView(image: icon_resized)
        
        let position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let marker = GMSMarker(position: position)
        marker.iconView = markerView
        marker.tracksViewChanges = true
        marker.map = mapView

    }
    
    // Pass your source and destination coordinates in this method.
    func drawPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D,density: Int){
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(Strings.locationAPIKey)")!
        print("\(url)\n")
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))\n")   // original url request
            print("Response: \(String(describing: response.response))\n") // http url response
            print("Result: \(response.result)\n")                         // response serialization result
            
            if let result = response.result.value {
                let json = result as! NSDictionary
                print(json)
                
                let routes = json["routes"] as? [Any]
                if routes?.count == 0
                {
                    return
                }
                else{
                    
                    let inside_routes = routes?[0] as? [String: Any]
                    
                    //find polyline in returned data to draw
                    let overview_polyline = inside_routes?["overview_polyline"] as?[String: String]
                    let polyString = overview_polyline?["points"]
                    
                    //Call this method to draw path on map
                    self.showPath(polyStr: polyString!,density: density)
                    
                    if self.stageOfSubmission != 0
                    {
                        //find distance in returned data to show
                        let legs = inside_routes?["legs"] as? [Any]
                        let inside_legs = legs?[0] as? [String: Any]
                        let distance = inside_legs?["distance"] as? [String: Any]
                        let distance_text = distance?["text"] as? String
                        self.submitDistance = distance_text!
                        
                        //find place name in returned data to show
                        let start_address = inside_legs?["start_address"] as? String
                        self.submitPlaceName = start_address!
                        
                    }
                }
                
            }

        }
    }
    
    //get place name
    func getName(source: CLLocationCoordinate2D)
    {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(source.latitude),\(source.longitude)&key=\(Strings.geocodeAPIKey)" )!
        print("\(url)\n")
        Alamofire.request(url).responseJSON { response in
            print("Request: \(String(describing: response.request))\n")   // original url request
            print("Response: \(String(describing: response.response))\n") // http url response
            print("Result: \(response.result)\n")                         // response serialization result
            
            if let result = response.result.value {
                let json = result as! NSDictionary
                print(json)
                
                let result = json["results"] as? [Any]
                if result?.count == 0
                {
                    return
                }
                else{
                    
                    let inside_result = result?[0] as? [String: Any]
                    
                    //find polyline in returned data to draw
                    let formatted_address = inside_result?["formatted_address"] as?String
                    
                    self.submitPlaceName = formatted_address!
                }
                
            }
            
        }
    }

    //draw circle on the Google Maps
    func drawCircle(source: CLLocationCoordinate2D,radius: Int,level: Int,eventID: String)
    {
        //draw flooded area in circle
        let circleCenter = source
        let circ = GMSCircle(position: circleCenter, radius: CLLocationDistance(radius))
        circ.strokeColor = UIColor.clear

        switch level {
        case -1:
            circ.fillColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1)
            circ.strokeColor = UIColor.blue
        case 0...10:
            circ.fillColor = UIColor(red: 1, green: 1, blue: 0, alpha: CIRCLE_ALPHA)
            //circ.strokeColor = UIColor.yellow
        case 11...50:
            circ.fillColor = UIColor(red: 1, green: 128/255, blue: 0, alpha: CIRCLE_ALPHA)
            //circ.strokeColor = UIColor.orange
        case 51...100:
            circ.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: CIRCLE_ALPHA)
            //circ.strokeColor = UIColor.red
        case 100...300:
            circ.fillColor = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: CIRCLE_ALPHA)
            //circ.strokeColor = UIColor.brown
        default:
            break
        }
  
        circ.strokeWidth = 3
        circ.title = eventID
        circ.map = mapView
        circ.isTappable = true
        circleArray.append(circ)
        
        if level == -1
        {
            demoCircle = circ
        }
        else{
            //set marker for the area
            let marker = GMSMarker()
            marker.position = source
            marker.title = eventID
            marker.map = mapView
            markerArray.append(marker)
        }
    }
    
    func showPath(polyStr :String,density: Int){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        switch density {
        case -1:
            polyline.strokeColor = UIColor.blue
        case 0:
            polyline.strokeColor = UIColor.green
        case 1:
            polyline.strokeColor = UIColor.yellow
        case 2:
            polyline.strokeColor = UIColor.orange
        case 3:
            polyline.strokeColor = UIColor.red
        case 4:
            polyline.strokeColor = UIColor.brown
        default:
            break
        }
        
        // Your map view
        polyline.map = mapView
        polylineArrays.append(polyline)
        if density == -1
        {
            directionLine = polyline
        }
    }
    
    func getUserLocation()
    {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
   
    func changeImageSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resetUserInfo()
    {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set("", forKey: "Email")
        UserDefaults.standard.set("", forKey: "Password")
        UserDefaults.standard.set("", forKey: "UserName")
        UserDefaults.standard.set("", forKey: "Phone")
        UserDefaults.standard.set("", forKey: "Address")
        UserDefaults.standard.set("", forKey: "Token")
        UserDefaults.standard.set("", forKey: "UserID")
        avatarImgView.image = #imageLiteral(resourceName: "user")
    }
    
    ////Button actions
    @IBAction func locationPressed(_ sender: Any) {
        
        let camera = GMSCameraPosition.camera(withLatitude: userLatitude,
                                              longitude: userLongtitude,
                                              zoom: 15.0)
        mapView.animate(to: camera)    }
    
    func moveToLocation(zoomLevel: Float)
    {
        getUserLocation()
        let camera = GMSCameraPosition.camera(withLatitude: userLatitude,
                                              longitude: userLongtitude,
                                              zoom: zoomLevel)
        mapView.animate(to: camera)
        if userChangedLocation
        {
            userLocMarker?.map = nil
            userLocMarker?.map = nil
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongtitude))
            marker.title = "Your Location"
            marker.map = mapView
            userLocMarker = marker
            sourceMarker = marker
        }
        
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        self.blackView.isHidden = false
        self.leadingConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Chú ý!!!", message: "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Đồng ý", style: UIAlertActionStyle.default, handler: {action in
            self.resetUserInfo()
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)

        }))
        alert.addAction(UIAlertAction(title: "Hủy", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func accountSettingPressed(_ sender: Any) {
//        let facebookURL = URL(fileURLWithPath: "fb://profile/798962816930247")
//        let webURL =  URL(fileURLWithPath: "https://web.facebook.com/798962816930247/")
//        if UIApplication.shared.canOpenURL(facebookURL)
//        {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(facebookURL, options: [:], completionHandler: nil)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//        else{
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        
    }
    
    @IBAction func locationSettingPressed(_ sender: Any) {
        blackView2.isHidden = true
        alertView.isHidden = true
        if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
            // If general location settings are disabled then open general location settings
            UIApplication.shared.openURL(url)
        }    }
    
    @IBAction func removePlacePressed(_ sender: Any) {
        UIView.animate(withDuration: 0.7, animations: {
            self.placeLocMarker?.map = nil
            self.removePlaceButt.isHidden = true
            self.searchImgView.isHidden = false
            self.placeLb.text = ""
        })
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        mapView.clear()
        if stageOfSubmission == 0
        {
            moveToLocation(zoomLevel: 17.0)
            submitText.text = "Do you want to set your location as flooded point. Or else you can tap on map to choose different point"
            stageOfSubmission = 1
            self.submitViewConstraint.constant = 23
            self.gpsButtConstraint.constant = -50
            self.submitButtConstraint.constant = -50
            self.densBoardConstraint.constant = -150
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func layerPressed(_ sender: Any) {
        
    }
    
    @IBAction func okPressed(_ sender: Any) {
        if sourceCoordinate == nil && stageOfSubmission == 1
        {
            var coordinate = CLLocationCoordinate2D()
            coordinate.latitude = userLatitude
            coordinate.longitude = userLongtitude
            sourceCoordinate = coordinate
            stageOfSubmission += 1
            handleSubmitStage()
        }
        else {
            stageOfSubmission += 1
            handleSubmitStage()
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        if stageOfSubmission == 1
        {
            closeSubmitView()
            loadDB()
        }
        else
        {
            stageOfSubmission -= 1
            handleSubmitStage()
        }
    }
    
    func handleSubmitStage()
    {
        if stageOfSubmission == 1
        {
            submitView2Constraint.constant = -200
            submitViewConstraint.constant = 23
            submitText.text = "Do you want to set your location as flooded point. Or else you can tap on map to choose different point"
            
            UIView.animate(withDuration: 0.5, animations:{
                self.view.layoutIfNeeded()
            })
        }
        else if stageOfSubmission == 2
        {
            demoCircle?.map = nil
            distanceLbConstraint.constant = -150
            submitViewConstraint.constant = -150
            submitView2Constraint.constant = 23
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else if stageOfSubmission == 3
        {
            submitView2Constraint.constant = -200
            submitViewConstraint.constant = 23
            getName(source: sourceCoordinate!)
            self.submitText.text = ""
            self.submitText.text = "This is what we will show on the map:"
            self.distanceLb.isHidden = false
            self.distanceLb.text = "Radius: \(self.radius!) m"
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else if stageOfSubmission == 4
        {
            stageOfSubmission -= 1
            let vc = SubmitDetailsViewController()
            vc.placeName = submitPlaceName
            vc.radius = radius
            vc.start_coor = sourceCoordinate
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func afterSubmit()
    {
        self.closeSubmitView()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            let alert = UIAlertController(title: "Thank you!", message: "Successfully Updated.Thank you for your contribution!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIlertAction in
                self.loadDB()
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    @objc func afterLogin() {
        if getClusterResponse != nil {
            self.hideLoading()
        }
        self.startAnimate()
    }

    func startAnimate() {
        self.gpsButtConstraint.constant = 10
        self.submitButtConstraint.constant = 10
        self.densBoardConstraint.constant = 10
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func closeSubmitView()
    {
        mapView.clear()
        sourceCoordinate = nil
        directionLine?.map = nil
        sourceMarker?.map = nil
        destMarker?.map = nil
        distanceLb.isHidden = true
        submitDistance = ""
        submitPlaceName = ""
        stageOfSubmission = 0
        self.gpsButtConstraint.constant = 10
        self.submitButtConstraint.constant = 10
        self.densBoardConstraint.constant = 10
        submitViewConstraint.constant = -150
        submitView2Constraint.constant = -200
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    ////table view functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingIconList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewTableViewCell") as! HomeViewTableViewCell
        cell.populate(title: settingTitleList[indexPath.row], image: settingIconList[indexPath.row], index: indexPath.row)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = NotificationViewController()
            self.present(vc, animated: true, completion: nil)
            
        case 1:
            let vc = FavoriteViewController()
            self.present(vc, animated: true, completion: nil)
        
        case 2:
            let vc = FeedbackViewController()
            self.present(vc, animated: true, completion: nil)
        
        case 3:
            let vc = RewardViewController()
            self.present(vc, animated: true, completion: nil)
            
        default:
            break
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if stageOfSubmission == 0 {
            if userLongtitude != locValue.longitude && userLatitude != locValue.latitude {
                userLatitude = locValue.latitude
                userLongtitude = locValue.longitude
                userChangedLocation = true
                print("locations = \(locValue.latitude) \(locValue.longitude)")
                let location = locations.last
                let zoomLevel = stageOfSubmission != 0 ? 17.0 : 13.0
                let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: Float(zoomLevel))
                self.mapView?.animate(to: camera)
                self.locationManager.stopUpdatingLocation()
            } else {
                userChangedLocation = false
            }
        }
    }
}

extension HomeViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if stageOfSubmission == 1 || stageOfSubmission == 2
        {
            placeLocMarker?.map = nil
            destMarker?.map = nil
            
            let position = coordinate
            let marker = GMSMarker(position: position)
            marker.title = placeTitle
            marker.map = mapView
            if stageOfSubmission == 1
            {
                sourceMarker?.map = nil
                sourceMarker = marker
                sourceCoordinate = coordinate
            }
            else
            {
                destMarker = marker
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        for x in traffics {
            for y in x.eventList! {
                if marker.title == y.id {
                    let alert = CustomAlertView(trafficInfo: y)
                    alert.show(animated: true)
                }
            }
        }
        
        return true
    }
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place lat: \(place.coordinate.latitude) and place long: \(place.coordinate.longitude)")
        placeLatitude = place.coordinate.latitude
        placeLongtitude = place.coordinate.longitude
        
        placeTitle = place.name
        moveToPlace()

        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


