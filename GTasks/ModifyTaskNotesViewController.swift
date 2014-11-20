//
//  ModifyTaskNotesViewController.swift
//  GTasks
//
//  Created by Jai on 07/11/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class ModifyTaskNotesViewController: UIViewController, UITextViewDelegate {
    
    var noteField:NotesTextView? = nil

    
    override init() {
        super.init()
        self.view.backgroundColor = UIColor.whiteColor()
        var bounds = self.view.bounds
        
        self.noteField = NotesTextView(frame: CGRectMake(bounds.minX + 5, bounds.minY + 5, bounds.width - 10, bounds.height - 10))
        //noteField?.placeholder = "Enter the task title/description"
        noteField?.autocorrectionType = UITextAutocorrectionType.Yes
        noteField?.returnKeyType = UIReturnKeyType.Done
        noteField?.delegate = self
        noteField?.scrollEnabled = true
        noteField?.editable = true
        noteField?.userInteractionEnabled = true
        noteField?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        noteField?.placeholderText = "Task Notes"

    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
