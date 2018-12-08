//
//  CommuterAPI.swift
//  Commuter
//
//  Created by Will Gilman on 12/2/18.
//  Copyright © 2018 BGHFM. All rights reserved.
//

import Foundation
import Alamofire
import Unbox

class CommuterAPI: NSObject {
    static let sharedClient = CommuterAPI(baseURL: "http://localhost:4000/api/v1")
    var baseURL: String
    let headers = ["content-type": "application/json"]
    var af: Alamofire.SessionManager?
    
    init(baseURL: String) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        self.af = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getStations(success: @escaping ([Station]) -> (), failure: @escaping (Error, String?) -> ()) {
        af?.request(self.baseURL + "/stations").validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    do {
                        let response = result as! Dictionary<String, Any>
                        let stations: [Station] = try Station.withArray(dictionaries: response["data"] as! Array)
                        success(stations)
                    } catch {
                        // Handle failure.
                    }
                }
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func getTrip(orig: String, dest: String, count: Int = 10, success: @escaping (Trip) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/departures?orig=\(orig)&dest=\(dest)&count=\(count)"
        af?.request(url).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    do {
                        let response = result as! Dictionary<String, Any>
                        let trip: Trip = try unbox(dictionary: response)
                        success(trip)
                    } catch {
                        // Handle failure.
                    }
                }
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    private func getErrorMessage(error: Error, response: DataResponse<Any>) -> String? {
        if let data = response.data {
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
                if dict?["message"] != nil {
                    return dict?["message"]
                }
            } catch {
                // Unhandled.
            }
        }
        return "An error occurred"
    }
}
