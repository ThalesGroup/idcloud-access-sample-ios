//
//
// Copyright © 2022 THALES. All rights reserved.
//


import UIKit
import D1

struct RiskAgent {
    static var userAgent: String?

    private static var riskTask: D1Task = {
        var comp = D1Task.Components()
        comp.riskURLString = Configuration.ndURL
        comp.riskClientID = Configuration.riskClientID
        return comp.task()
    }()

    static func sdkVersion() -> String {
        return D1Task.getSDKVersions()["D1"] ?? ""
    }

    static func startAnalyze(view: UIView, completion: @escaping (IDCAError?) -> Void) {
        let params = RiskParams(view: view, placementName: "LoginMobile", placementPage: 1)
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

    static func submitRiskPayload(completion: @escaping (String?, IDCAError?) -> Void) {
        riskTask.stopAnalyze { riskPayload, error in
            if let error = error {
                let idcaError = IDCAError(riskError: error)
                DispatchQueue.main.async {
                    completion(nil, idcaError)
                }
                return
            }

            guard let riskPayload = riskPayload else {
                fatalError("Risk payload not found")
            }

            submitPayload(riskPayload) { riskID, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let idcaError = IDCAError(code: .unknown, description: error.localizedDescription)
                        completion(nil, idcaError)
                    }
                    return
                }

                guard let riskID = riskID else {
                    fatalError("RiskID not found")
                }
                DispatchQueue.main.async {
                    Logger.log("RiskID: \(riskID)")
                    completion(riskID, nil)
                }
            }
        }
    }

    static func pauseAnalyze() {
        Logger.log("Risk analysis paused")
        riskTask.pauseAnalyze()
    }

    // MARK: Private Methods

    private static func submitPayload(_ payload: Data, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "\(Configuration.riskURL)/riskstorage") else {
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
        urlRequest.httpBody = payload

        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession.init(configuration: sessionConfiguration)
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                fatalError("Invalid http status code")
            }

            guard let jsonResponse = try? JSONSerialization.jsonObject(with: data!) as? [String: Any],
                  let riskId = jsonResponse["payloadId"] as? String else {
                fatalError("Unexpected response")
            }

            DispatchQueue.main.async {
                completion(riskId, nil)
            }
            return
        }.resume()
    }
}
