//
//  HDHM01ViewController.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/1/4.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SnapKit

class HDHM01Controller: BaseViewController {
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        
        Alamofire.request(.GET, Constants.HDHM01_URL)
            .responseJSON { response in
        
                print("\(response.result.value)")
                
                
        }


    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


