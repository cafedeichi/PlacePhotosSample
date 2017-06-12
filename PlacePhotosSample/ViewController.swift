//
//  ViewController.swift
//  PlacePhotosSample
//
//  Created by ichi on 2017/06/10.
//  Copyright © 2017年 Rhzome Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ViewController: UIViewController {
    
    //FIXME: Enter your API Key.
    let myAPIKey = "+++ Your API Key +++"
    let placeDetailURL = "https://maps.googleapis.com/maps/api/place/details/json"
    let placePhotoURL = "https://maps.googleapis.com/maps/api/place/photo"
    var json: JSON = []

    @IBOutlet weak var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        
        let parameters = ["placeid":"ChIJN1t_tDeuEmsRUsoyG83frY4",
                          "key":myAPIKey]
        
        Alamofire.request(self.placeDetailURL,method: .get,parameters: parameters).responseJSON { (response) in
            
            guard let object = response.result.value else {
                return
            }
            
            self.json = JSON(object)
            
            self.carousel.type = .linear
            self.carousel.isVertical = true
            self.carousel.delegate = self
            self.carousel.dataSource = self
            
        }
        
    }

}

extension ViewController: iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        switch option {
        case .spacing:
            return value * 1.1
        case .wrap:
            return 1.0
        default:
            return value
        }

    }
    
}

extension ViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.json["result"]["photos"].count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        var itemView: UIImageView
        
        if let view = view as? UIImageView {
            itemView = view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            
            let parameters = ["maxwidth":"800",
                "photoreference":self.json["result"]["photos"][index]["photo_reference"].stringValue,
                "key":myAPIKey]
            
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            itemView.contentMode = .center
            itemView.clipsToBounds = true

            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = label.font.withSize(50)
            label.textColor = UIColor.white
            label.tag = 1
            
            Alamofire.request(self.placePhotoURL, method: .get, parameters: parameters).responseImage(completionHandler: { (response) in
                
                guard let image = response.result.value else {
                    return
                }
                
                itemView.image = image
                itemView.addSubview(label)
                
            })
            
        }
        
        label.text = "\(index)"
        return itemView

    }
    
}
