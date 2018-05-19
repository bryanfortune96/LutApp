//
//  APIRouter.swift
//  Banana
//

import Alamofire
import ObjectMapper
let baseServerURL = "https://lutserver.herokuapp.com/"


enum BananaRouter: URLRequestConvertible {
    
    case GetEventList(userID: String)
    case GetUser(userID: String,token: String)
    case PostUser(param: Dictionary<String, Any>)
    case Login(param: Dictionary<String, Any>)
    case GetEvent(eventID: String)
    case PostEvent(param: Dictionary<String, Any>,token: String)
    case Register(param: Dictionary<String, Any>)
    case UpdateUser(param: Dictionary<String,Any>,token: String,userID: String)
    case UpdatePassword(param: Dictionary<String,Any>,token: String,userID: String)
    case UpvoteEvent(param: Dictionary<String, Any>)
    case DownvoteEvent(eventID: String,token: String)
    case GetLeaderboardAllTime()
    case GetLeaderboardMonth(time: String)
    case GetLeaderboardYear(time: String)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .GetEventList( _):
            return .get
        case .GetUser( _, _):
            return .get
        case .PostUser( _):
            return .post
        case .Login( _):
            return .post
        case .GetEvent( _):
            return .get
        case .PostEvent( _, _):
            return .post
        case .Register( _):
            return .post
        case .UpdateUser( _, _,let _):
            return .put
        case .UpdatePassword( _, _,let _):
            return .put
        case .UpvoteEvent( _):
            return .post
        case .DownvoteEvent( _, _):
            return .post
        case .GetLeaderboardAllTime():
            return .get
        case .GetLeaderboardYear( _):
            return .get
        case .GetLeaderboardMonth( _):
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .GetEventList(let userID):
            return "clustersAll/\(userID)"
        case .GetUser(let userID, _):
            return "user/\(userID)"
        case .PostUser( _):
            return "user"
        case .Login( _):
            return "user/login"
        case .GetEvent(let eventID):
            return "events/\(eventID)"
        case .PostEvent( _, _):
            return "events"
        case .Register( _):
            return "user"
        case .UpdateUser( _, _,let userID):
            return "user/\(userID)"
        case .UpdatePassword( _, _,let userID):
            return "user/password/\(userID)"
        case .UpvoteEvent(let param):
            let eventID = param["eventId"] as! String
            return "events/upvote/\(String(describing: eventID))"
        case .DownvoteEvent(let eventID, _):
            return "events/downvote/\(eventID)"
        case .GetLeaderboardAllTime():
            return "leaderboard"
        case .GetLeaderboardMonth(let time):
            return "leaderboard/month/\(time)"
        case .GetLeaderboardYear(let time):
            return "leaderboard/year/\(time)"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url:URL?
        //send params to url
        switch self {
        default:
            let string = "\(baseServerURL)\(path)"
            url = URL.init(string: string)
            //url = URL(string: (baseServerURL as NSString).appendingPathComponent(path))!
            break;
        }
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        //send params to httpBody
        switch self {
            
        case .UpdateUser(let param, _, _):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            break
        case .UpdatePassword(let param, _, _):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            break
        case .PostUser(let param):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            break;
        case .Login(let param):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            break;
        case .PostEvent(let param, let token):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
            break;
        case .Register(let param):
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
        case .UpvoteEvent(let param):
            let input = ["userId": param["userId"], "score": param["score"]]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: input, options: JSONSerialization.WritingOptions.prettyPrinted)
        default:
            break;
        }
        
        //send header to httpHeader
        switch self {
        case .PostEvent( _,let token):
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            break
        case .UpdatePassword( _,let token, _):
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            break
        case .UpdateUser( _,let token, _):
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        case .UpvoteEvent(let param):
            let token = param["token"] as? String
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        case .DownvoteEvent( _,let token):
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        case .GetUser( _,let token):
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        default:
            break
        }
        
        return urlRequest
    }
}
