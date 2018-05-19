//
//  ObjectMapper.swift
//  Banana
//


import ObjectMapper


class EventListResponse: BaseResponse {
    var data : [EventDetailsObject]?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class ClusterListResponse: BaseResponse {
    var data : [ClusterDetailsObject]?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class EventDetailsResponse: BaseResponse {
    var data : EventDetailsObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class LoginResponse: BaseResponse {
    var data: UserInfoObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class PostEventResponse: BaseResponse {
    var data: EventDetailsObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class RegisterResponse: BaseResponse {
    var data: RegisterObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class UpdateUserResponse: BaseResponse {
    var data: UserUpdateObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class UpdatePasswordResponse: BaseResponse {
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}

class UpvoteEventResponse: BaseResponse {
    var data: VoteResponseObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class DownvoteEventResponse: BaseResponse {
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}

class GetLeaderBoardResponse: BaseResponse {
    var data: [UsersObject]?
    override func mapping(map: Map)  {
        super.mapping(map: map)
        data <- map["data"]
    }
}

class GetUserResponse: BaseResponse {
    var data: UsersObject?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}


class UsersObject: NSObject, Mappable {
    
    var id: String?
    var email: String?
    var point: Int?
    var level: Int?
    var phone: String?
    var address: String?
    var nickname: String?
    var date: String?
    var queryPoint: Int?
    var avatarImgPath: String? = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        email <- map["email"]
        point <- map["reputation"]
        level <- map["level"]
        phone <- map["phone"]
        address <- map["address"]
        nickname <- map["nickname"]
        date <- map["created_at"]
        queryPoint <- map["queryTimePoints"]
        avatarImgPath <- map["avatar"]
    }
}

class ClusterDetailsObject: NSObject, Mappable {
    var eventList: [EventDetailsObject]?
    var level: Int?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        eventList <- map["Events"]
        level <- map["level_now"]
    }
}

class EventDetailsObject: NSObject, Mappable {
    
    var id: String?
    var name: String?
    var author: UsersObject?
    var startLatitude: Float?
    var startLongtitude: Float?
    var level: Int?
    var radius: Int?
    var reasons: Int?
    var nextLevel: Int?
    var updatedAt: String?
    var createdAt: String?
    var district: Int?
    var imagePaths: [String]?
    var points: PointsObject?
    var alreadyVoted: Bool?
    var validity: Double?
    var votedScore: Double? = 3.0
    
    public required init?(map: Map) {
    }
    
    public override init() {
    }
    
    func mapping(map: Map) {
        
        id <- map["_id"]
        name <- map["name"]
        author <- map["userId"]
        startLatitude <- map["latitude"]
        startLongtitude <- map["longitude"]
        radius <- map["radius"]
        level <- map["water_level"]
        reasons <- map["reasons"]
        nextLevel <- map["estimated_next_level"]
        updatedAt <- map["updated_at"]
        createdAt <- map["created_at"]
        district <- map["district"]
        imagePaths <- map["mediaDatas"]
        points <- map["Point"]
        alreadyVoted <- map["isUpvoted"]
        validity <- map["validity"]
    }
}

class PointsObject: NSObject,Mappable {
    var votedUserIDs: [String] = []
    var points: Double?
    
    public required init?(map: Map) {
    }
    
    public override init() {
    }
    
     func mapping(map: Map) {
        points <- map["points"]
        votedUserIDs <- map["VotedUsers"]
    }
        
}

class UserInfoObject: NSObject, Mappable {
    var id: String?
    var userName: String?
    var phoneNo: String?
    var address: String?
    var token: String?
    
    public required init?(map: Map) {
    }
    
    public override init() {
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userName <- map["nickname"]
        phoneNo <- map["phone"]
        address <- map["address"]
        token <- map["token"]
    }
    
}


class RegisterObject: NSObject, Mappable {
    var id: String?
    var userName: String?
    var phoneNo: String?
    var address: String?
    
    public required init?(map: Map) {
        
    }
    
    public override init() {
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userName <- map["nickname"]
        phoneNo <- map["phone"]
        address <- map["address"]
    }
    
}

class UserUpdateObject: NSObject, Mappable {
    var id: String?
    var userName: String?
    var phoneNo: String?
    var address: String?
    var email: String?
    public required init?(map: Map) {
        
    }
    
    public override init() {
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        userName <- map["nickname"]
        phoneNo <- map["phone"]
        address <- map["address"]
        email <- map["email"]
    }
    
}

class VoteResponseObject: NSObject, Mappable {
    var point: PointsObject?
    var eventId: String?
    var authorId: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        point <- map["Point"]
        authorId <- map["userId"]
        eventId <- map["_id"]
    }
}









