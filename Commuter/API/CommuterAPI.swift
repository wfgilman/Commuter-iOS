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
import MapKit

class CommuterAPI: NSObject {
    static let sharedClient = CommuterAPI(baseURL: AppVariable.baseURL)
    var baseURL: String
    let headers = ["content-type": "application/json"]
    var af: Alamofire.SessionManager?
    
    init(baseURL: String) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
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
    
    func getTrip(origCode: String, destCode: String, count: Int = 10, realTime: Bool = true, success: @escaping (Trip) -> (), failure: @escaping (Error, String?) -> ()) {
        var url: URLConvertible
        if let deviceId = AppVariable.deviceId {
            url = self.baseURL + "/departures?orig=\(origCode)&dest=\(destCode)&count=\(count)&real_time=\(realTime)&device_id=\(deviceId)"
        } else {
            url = self.baseURL + "/departures?orig=\(origCode)&dest=\(destCode)&count=\(count)&real_time=\(realTime)"
        }
        af?.request(url).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    do {
                        let response = result as! Dictionary<String, Any>
                        let trip: Trip = try unbox(dictionary: response)
                        success(trip)
                    } catch {
                        // Handle error.
                    }
                }
            case .failure(let error):
                let name = NSNotification.Name("failedLoad")
                NotificationCenter.default.post(name: name, object: nil)
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    enum NotificationAction: String {
        case store
        case delete
    }
    
    func setNotification(deviceId: String, tripId: Int, stationCode: String, action: NotificationAction, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/notifications"
        var params: Parameters = ["device_id" : deviceId, "trip_id" : tripId, "station_code" : stationCode]
        if action == .delete {
            params["remove"] = true
        }
        let header: HTTPHeaders = ["content-type": "application/json"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header)
            .validate()
            .responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                success()
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func deleteNotification(notification: Notification, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/notifications/\(notification.id)"
        af?.request(url, method: .delete).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let message = self.getErrorMessage(error: error, response: response)
                    failure(error, message)
                }
            })
    }
    
    func getNotifications(success: @escaping ([Notification]) -> (), failure: @escaping (Error, String?) -> ()) {
        guard let deviceId = AppVariable.deviceId else { return }
        let url: URLConvertible = self.baseURL + "/notifications?device_id=\(deviceId)"
        af?.request(url).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    do {
                        let response = result as! Dictionary<String, Any>
                        AppVariable.muted = response["muted"] as! Bool
                        let notifications: [Notification] = try Notification.withArray(dictionaries: response["notifications"] as! Array)
                        success(notifications)
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
    
    enum NotificationSettingAction: String {
        case mute
        case unmute
    }

    func setDeviceNotificationSetting(action: NotificationSettingAction, success: @escaping () -> (), failure: @escaping (Error, String?) -> ()) {
        guard let deviceId = AppVariable.deviceId else {
            // Inform user he doesn't have any notifications setup yet.
            return
        }
        var params: Parameters = ["device_id" : deviceId, "mute" : true]
        if action == .unmute {
            params["mute"] = false
        }
        let url: URLConvertible = self.baseURL + "/notifications/action"
        let header: HTTPHeaders = ["content-type": "application/json"]
        af?.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                success()
            case .failure(let error):
                let message = self.getErrorMessage(error: error, response: response)
                failure(error, message)
            }
        })
    }
    
    func getEta(location: CLLocation, origCode: String, destCode: String, success: @escaping (ETA) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/eta?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&orig=\(origCode)&dest=\(destCode)"
        af?.request(url).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    do {
                        let response = result as! Dictionary<String, Any>
                        let eta: ETA = try unbox(dictionary: response)
                        success(eta)
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
    
    func getAdvisory(success: @escaping (String?) -> (), failure: @escaping (Error, String?) -> ()) {
        let url: URLConvertible = self.baseURL + "/advisories"
        af?.request(url).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    let response = result as! Dictionary<String, Any>
                    let count = response["count"] as! Int
                    let advisory = response["advisory"] as! String
                    if count == 0 {
                        success(nil)
                    } else {
                        success(advisory)
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
                // Handle error.
            }
        }
        return "An error occurred."
    }
}
