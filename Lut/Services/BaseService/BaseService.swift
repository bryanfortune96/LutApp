//
//  BaseService.swift
//  Banana
//

import UIKit
import Alamofire
import Bolts
import ObjectMapper

open class BaseService: NSObject, BaseServiceProtocol {
    public var errorDomain: String {
        return "\(type(of:self)).errorDomain"
    }
    
    func makeRequest<T>(request: URLRequestConvertible, returnType: T.Type, isArrayResponse: Bool, showLoading: Bool = true) -> MyRequest where T : Mappable {
        return self.doRequest(request: request, returnType: returnType, isArrayResponse: isArrayResponse,showLoading: showLoading)
    }
    
}

