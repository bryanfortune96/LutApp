//
//  BaseResponse.swift
//  Banana
//


import ObjectMapper

class BaseResponse: NSObject, Mappable {
    var success: Bool?
    var message: String?
    //var token: String?
    public required init?(map: Map) {
    }
    
    public override init() {
    }
    
    func mapping(map: Map) {
        success <- map["success"]
        message   <- map["message"]
    }
}
