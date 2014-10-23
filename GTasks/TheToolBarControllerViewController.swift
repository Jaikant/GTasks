//
//  TheToolBarControllerViewController.swift
//  GTasks
//
//  Created by Jai on 06/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TheToolBarControllerViewController: UIViewController {
    
    var toolbar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.barStyle = UIBarStyle.Default
        var firsttoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.PageCurl, target: self, action: Selector("firstToolItemSelector"))
        
        var secondtoolitem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: Selector("secondToolItemSelector"))

        
        toolbar.items = [firsttoolitem, secondtoolitem]


        // Do any additional setup after loading the view.
    }
    
    
    func firstToolItemSelector() {
        
    }
    
    func secondToolItemSelector() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
