//
//  AlamoFireExt.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 4/3/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import Foundation
import Alamofire

// Alamofire is a great tool that makes things a lot simpler to code. Unfortunately its
// internal design does not promote easy extensibility. This is a small extension for
// supporting bundle based NSURL as transparently as possible on the user side

public struct URLLocalFileConvertible: Alamofire.URLStringConvertible {
    let val:String
    init(str:String) {
        val = str
    }
    public var URLString: String {
        return val
    }
}

extension String {
    func __conversion() -> URLLocalFileConvertible {
        return URLLocalFileConvertible(str: self)
    }

    public func localURL() -> URLLocalFileConvertible {
        return URLLocalFileConvertible(str:self)
    }
}

/// Rough simulation of the scoping offered by native modules
public class AlamofireExt {
    
    public static func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
          parameters: [String: AnyObject]? = nil,
          encoding: ParameterEncoding = .URL,
          headers: [String: String]? = nil)
        -> Request
    {
        if let url = URLString as? URLLocalFileConvertible {
            let mutableURLRequest = URLRequest(method, url, headers: headers)
            if let mutableURLRequest = mutableURLRequest {
                let encodedURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
                return Manager.sharedInstance.request(encodedURLRequest)
            } else {
                // normal path
                return Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
            }
        } else {
            // normal path
            return Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        }
    }
    
    static func URLRequest(
        method: Alamofire.Method,
        _ URLString: URLLocalFileConvertible,
          headers: [String: String]? = nil)
        -> NSMutableURLRequest?
    {
        guard let urlpath = NSBundle.mainBundle().pathForResource(URLString.URLString, ofType: nil) else {return nil}
        
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(fileURLWithPath: urlpath))
        mutableURLRequest.HTTPMethod = method.rawValue
            
        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        return mutableURLRequest
    }
}
