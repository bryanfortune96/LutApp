//
//  SubmitDetailsViewController.swift
//  Banana
//


import UIKit
import MarqueeLabel
import GoogleMaps
import BEMCheckBox
import Alamofire

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class SubmitDetailsViewController: BaseViewController {
    
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var imageCoverViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButt: UIButton!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLb: MarqueeLabel!
    @IBOutlet weak var levelSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var nextLevelSlider: UISlider!
    @IBOutlet weak var levelLb: UILabel!
    @IBOutlet weak var radiusLb: UILabel!
    @IBOutlet weak var nextLevelLb: UILabel!
    @IBOutlet weak var levelTitleLb: UILabel!
    @IBOutlet weak var nextLevelTitleLb: UILabel!
    @IBOutlet weak var rainCheckBox: BEMCheckBox!
    @IBOutlet weak var tidesCheckBox: BEMCheckBox!
    @IBOutlet weak var drainageCheckBox: BEMCheckBox!
    @IBOutlet weak var otherCheckBox: BEMCheckBox!
    
    var trafficImage: UIImage?
    var district: Int?
    var start_coor: CLLocationCoordinate2D?
    var placeName = ""
    var didChooseImage = false
    var isEditingImage = false
    var isWaterLevelWarning = false
    var radius: Int?
    var level: Int?
    var reasons: Int?
    var nextLevel: Int?
    var submitData: Dictionary<String,Any> = [:]
    var response: PostEventResponse?
    {
        didSet{
            //self.hideLoading()
            if (response?.success)!
            {
                self.submitResponse = response?.data
            }
            else{
                self.hideLoading()
                let alert = UIAlertController(title: "Warning!", message: response?.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    var submitResponse: EventDetailsObject?
    {
        didSet{
            let token = UserDefaults.standard.string(forKey: "Token")
            if trafficImage != nil {
                self.postImage(data: UIImageJPEGRepresentation(trafficImage!, 0.08)!, eventID: (submitResponse?.id)!, token: token!)
            } else {
                self.hideLoading()
                NotificationCenter.default.post(name: NSNotification.Name("CloseSubmitView"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    var currentIndexPath = 0
    var pickerList:[String] = []
    var submitSuceeded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }

    func initialize()
    {
        imageBottomConstraint.constant = SCREEN_HEIGHT
        imageCoverViewHeightConstraint.constant = SCREEN_HEIGHT - 300
        blackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(closeOptions)))
        blackView.isHidden = true

        // corner radius
        middleView.layer.cornerRadius = 10
        shadowView.layer.cornerRadius = 10
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        //check boxes
        rainCheckBox.boxType = .square
        tidesCheckBox.boxType = .square
        drainageCheckBox.boxType = .square
        otherCheckBox.boxType = .square
    
        // shadow
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 10
        
        titleLb.text = "\(placeName)                    "
        distanceLb.text = "\(String(describing: radius!)) m"
        
        //monitor slider value change
        radiusSlider.isContinuous = true
        levelSlider.isContinuous = true
        nextLevelSlider.isContinuous = true
        radiusSlider.addTarget(self, action: #selector(radiusValueChanged), for: .valueChanged)
        levelSlider.addTarget(self, action: #selector(levelValueChanged), for: .valueChanged)
        nextLevelSlider.addTarget(self, action: #selector(nextLevelValueChanged), for: .valueChanged)
        
        let a = Float(radius!) / 200.0
        radiusSlider.setValue(a, animated: false)
        radiusLb.text = String(describing: radius!)
        
        level = 30
        levelSlider.setValue(30/300, animated: false)
        levelLb.text = "\(level!)"
        
        nextLevel = -1
        nextLevelSlider.setValue(0/240, animated: false)
        nextLevelLb.text = "0"
    }
    
    func radiusValueChanged()
    {
        radius = Int(Double(radiusSlider.value) * 200)
        radiusLb.text = String(describing: radius!)
    }
    
    func levelValueChanged()
    {
        level = Int(Double(levelSlider.value) * 300)
        levelLb.text = String(describing: level!)
        if level! > 100 {
            if !isWaterLevelWarning {
                let alert = UIAlertController(title: "Warning!", message: "The water level is exceeding normal value. Please make sure you are choosing exactly!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                isWaterLevelWarning = true
            }
            
            levelSlider.tintColor = UIColor.red
            levelLb.textColor = UIColor.red
            levelTitleLb.textColor = UIColor.red
        } else {
            levelSlider.tintColor = self.view.tintColor
            levelLb.textColor = UIColor.black
            levelTitleLb.textColor = UIColor.black
        }
    }
    
    func nextLevelValueChanged()
    {
        nextLevel = Int(Double(nextLevelSlider.value) * 300)
        nextLevelLb.text = String(describing: nextLevel!)
        if nextLevel! > 100 {
            if !isWaterLevelWarning {
                let alert = UIAlertController(title: "Warning!", message: "The water level is exceeding normal value. Please make sure you are choosing exactly!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                isWaterLevelWarning = true
            }
            
            nextLevelSlider.tintColor = UIColor.red
            nextLevelLb.textColor = UIColor.red
            nextLevelTitleLb.textColor = UIColor.red
        } else {
            nextLevelSlider.tintColor = self.view.tintColor
            nextLevelLb.textColor = UIColor.black
            nextLevelTitleLb.textColor = UIColor.black
        }
    }
    
    func getDistrict()
    {
        let districts = DataMgr.shared.districts
        for x in districts
        {
            let title = "\(x.title),"
            if placeName.range(of: title) != nil
            {
                district = x.id
                return
            }
        }
    }
    
    func getReasons()
    {
        reasons = 0
        if rainCheckBox.on
        {
            reasons = reasons! + 1
        }
        if tidesCheckBox.on
        {
            reasons = reasons! + 10
        }
        if drainageCheckBox.on
        {
            reasons = reasons! + 100
        }
        if otherCheckBox.on
        {
            reasons = reasons! + 1000
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postImage(data: Data, eventID: String, token: String) {
        let URL = "https://lutserver.herokuapp.com/events/media/" + eventID
        print(URL)
        print(token)
        let request = try! URLRequest(url: URL, method: .put, headers: ["Content-Type": "application/x-www-form-urlencoded","Authorization": token])
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            let filename = eventID + ".jpeg"
            MultipartFormData.append(data, withName: "image", fileName: filename, mimeType: "image/jpeg")
        },
                         with: request,
                         encodingCompletion: { (result) in
                            switch result {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    let value = response.result.value as! [String: Any]
                                    print(value)
                                    self.hideLoading()
                                    NotificationCenter.default.post(name: NSNotification.Name("CloseSubmitView"), object: nil)
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            case .failure( _):
                                self.hideLoading()
                                self.showAlert(message: "Could not connect to server")
                            }
        })
    }
    
    func showSuccess() {
        let alert = UIAlertController(title: "Chú ý", message: "Cập nhật thông tin thành công!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleCameraOpening() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        if didChooseImage {
            isEditingImage = true
            imageBottomConstraint.constant = 0
            blackView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            handleCameraOpening()
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        if nextLevel == -1 {
            let alert = UIAlertController(title: "Warning!", message: "Please choose next water level in 5 minutes", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.showLoading()
            getDistrict()
            getReasons()
            nextLevel = nextLevel! * 60
            let token = UserDefaults.standard.string(forKey: "Token")
            let userID = UserDefaults.standard.string(forKey: "UserID")
            submitData = ["userId": userID!,"name": placeName, "latitude": Float((start_coor?.latitude)!),"longitude": Float((start_coor?.longitude)!), "water_level": level!,"radius": radius!,"estimated_next_level": nextLevel!,"reasons": reasons!]
            ServiceHelpers.postEvent(param: submitData, token: (token)!) { (response) in
                self.response = response
            }
        }
        
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePressed(_ sender: Any) {
    }
    
    @IBAction func chooseAnotherPressed(_ sender: Any) {
        handleCameraOpening()
    }
    
    @IBAction func deleteImagePressed(_ sender: Any) {
        trafficImage = nil
        didChooseImage = !didChooseImage
        cameraButt.setImage(#imageLiteral(resourceName: "camera_icon"), for: .normal)
        closeOptions()
    }
    
    @objc func closeOptions()
    {
        self.blackView.isHidden = true
        if isEditingImage {
            isEditingImage = !isEditingImage
            imageBottomConstraint.constant = SCREEN_HEIGHT
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
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


extension SubmitDetailsViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            trafficImage = pickedImage
            cameraButt.setImage(#imageLiteral(resourceName: "camera_checked_icon"), for: .normal)
            didChooseImage = true
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
}

extension SubmitDetailsViewController: UINavigationControllerDelegate {
    
}
