//
//  ViewController.swift
//  Millie
//
//  Created by 현은백 on 10/8/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        HTTPClient
            .shared
            .requestWithCustomError(
                endpoint: APIEndpoint.topHeadlines(country: "us")
            ) { (result: Result<NewsEntry, NetworkError>) in
                print(result.self)
            }
    }

}

