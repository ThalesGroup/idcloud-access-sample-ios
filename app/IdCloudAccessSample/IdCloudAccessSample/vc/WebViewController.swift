//
//
// Copyright © 2022 THALES. All rights reserved.
//


import UIKit
import WebKit

class WebViewController: UIViewController {
    private let webView: WKWebView
    private let url: URL
    private let activityIndicator: UIActivityIndicatorView = {
        var activityIndicator: UIActivityIndicatorView!
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    var redirectCallback: ((URL, (WKNavigationActionPolicy) -> Void) -> Void)?

    private var enrollmentToken: String?

    init(url: URL) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: configuration)
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .extBackground
        layout()
        let activityIndicatorBarButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = activityIndicatorBarButton

        webView.navigationDelegate = self

        let request = URLRequest(url: url)
        webView.load(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension WebViewController {
    func layout() {
        guard webView.translatesAutoresizingMaskIntoConstraints else {
            return
        }

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraints([
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let redirectCallback = redirectCallback else {
            decisionHandler(.cancel)
            return
        }
        redirectCallback(url, decisionHandler)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
