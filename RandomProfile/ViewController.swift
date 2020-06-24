//
//  ViewController.swift
//  apitest
//
//  Created by Inpyo Hong on 2020/06/24.
//  Copyright © 2020 Inpyo Hong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire
import Kingfisher
import PKHUD

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    var thumbnailImg = UIImage()
    var errorInfo: Error!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        HUD.show(.progress, onView: self.view)

        RxAlamofire.requestJSON(.get, "https://randomuser.me/api/")
        .debug("get profile")
        .subscribe(onNext: { [weak self] (r, json) in
            guard let self = self else { return }
            if let dict = json as? [String: AnyObject], let results = dict["results"] as? NSArray, let userInfo = results[0] as? [String: AnyObject] {
                print(userInfo)
                
                guard let name = userInfo["name"] as? [String: String], let firstName = name["first"], let lastName = name["last"], let picture = userInfo["picture"] as? [String: String], let thumbnailUrl = picture["large"] else {
                    return
                }
                
                self.userNameLabel.text = "\(firstName) \(lastName)"
 
                let resource = ImageResource(downloadURL: URL(string: thumbnailUrl)!)
                self.profileImgView.kf.setImage(with: resource) { result in
                    HUD.hide()
                    print("image download result", result)
                }
            }
        }, onError: { [weak self] (error) in
            guard let self = self else { return }
            self.errorInfo = error
            print(error)
        })
        .disposed(by: disposeBag)
               
    }
}

