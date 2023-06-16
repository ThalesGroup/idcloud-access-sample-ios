//
//
// Copyright © 2022 THALES. All rights reserved.
//


import UIKit
import D1

struct RiskAgent {
    static var userAgent: String?
    
    static let placementName = "LoginMobile"

    private static var riskTask: D1Task = {
        var comp = D1Task.Components()
        comp.riskURLString = Settings.ndURLString
        comp.riskClientID = Settings.riskClientID
        return comp.task()
    }()

    static func sdkVersion() -> String {
        return D1Task.getSDKVersions()["D1"] ?? ""
    }

    static func startAnalyze(view: UIView, completion: @escaping (IDCAError?) -> Void) {
        let params = RiskParams(view: view, placementName: placementName, placementPage: 1)
        DispatchQueue.global(qos: .userInitiated).async {
            RiskAgent.riskTask.startAnalyze(params) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        let idcaError = IDCAError(riskError: error)
                        completion(idcaError)
                    } else {
                        Logger.log("Risk analysis started")
                        completion(nil)
                    }
                }
            }
        }
    }

    static func submitRiskPayload(username: String, completion: @escaping (String?, IDCAError?) -> Void) {
        riskTask.stopAnalyze { sdkPayload, error in
            if let error = error {
                let idcaError = IDCAError(riskError: error)
                DispatchQueue.main.async {
                    completion(nil, idcaError)
                }
                return
            }
            guard let sdkPayload = sdkPayload,
                  let sdkPayloadJson = try? JSONSerialization.jsonObject(with: sdkPayload,
                                                                         options: .mutableContainers) as? [String: AnyObject],
                  var ndsJson = sdkPayloadJson["nds"] as? [String: Any] else {
                fatalError("Risk payload not found")
            }
            
            // This is a temporary modification to the output from the IdCloud Risk SDK.
            // At present, the output from the SDK is out-of-sync with what is expected
            // by the IdCloud Risk servers.
            // To remove timestamp and rename the 'nds' -> 'environmentData'
            ndsJson.removeValue(forKey: "timestamp")
            let sessionID = ndsJson["sessionId"] ?? ""
            
            let riskPayload: [String: Any] = [
                "accountInfo": [
                    "internalAccountId": username,
                    "userName": username,
                    "emailAddress": username,
                ],
                "environmentData": ndsJson
            ]
            
            submitPayload(riskPayload) { riskID, error in
                if let error = error {
                    DispatchQueue.main.async {
                        if let idcaError = error as? IDCAError {
                            completion(nil, idcaError)
                        } else {
                            let idcaError = IDCAError(code: .unknown, description: error.localizedDescription)
                            completion(nil, idcaError)
                        }
                    }
                    return
                }
                
                guard let riskID = riskID else {
                    fatalError("RiskID not found")
                }
                Logger.log("RiskID: \(riskID)")

                DispatchQueue.main.async {
                    let acrRiskID = "\(placementName):\(sessionID)"
                    // Risk ID is no longer required for ACR
                    completion(acrRiskID, nil)
                }
            }
        }
    }

    static func pauseAnalyze() {
        Logger.log("Risk analysis paused")
        riskTask.pauseAnalyze()
    }

    // MARK: Private Methods

    private static func submitPayload(_ payload: [String: Any], completion: @escaping (String?, Error?) -> Void) {
        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload,
                                                       options: .sortedKeys) else {
            fatalError("Unable to construct payload data")
        }
        
        guard let url = URL(string: "\(Settings.riskURLString)/push") else {
            fatalError("Unable to construct risk URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        if let userAgent = userAgent {
            urlRequest.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = payloadData

        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession.init(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Invalid URLResponse type")
            }
            
            if httpResponse.statusCode != 200 {
                let idcaError = IDCAError(code: .http, description: "Risk payload submission error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(nil, idcaError)
                }
                return
            }

            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!) as? [String: Any],
                  let riskId = jsonResponse["rid"] as? String else {
                fatalError("Unexpected response")
            }

            DispatchQueue.main.async {
                completion(riskId, nil)
            }
            return
        }.resume()
    }
}
