//
//  NotesTextView.swift
//  GTasks
//
//  Created by Jai on 14/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class NotesTextView: UITextView {
    
    
    var placeholderLabel : UILabel?
    var placeholderText : String?
    var placeholderColor = UIColor.grayColor()
    let animationDuration : NSTimeInterval = 0.25
    
    func textChanged(notif : NSNotification) -> Void {
        
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.placeholderText = ""
        self.text = ""
        self.placeholderColor = UIColor.lightGrayColor()
        
        var notifycentre = NSNotificationCenter.defaultCenter()
        notifycentre.addObserver(self, selector: "textChangedFunction", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    
    func textChangedFunction() -> Void {
        LogError.log("text Changed value of text is \(self.text)")
        if self.placeholderText == "" {
            return
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            if self.text == "" {
                self.viewWithTag(999)?.alpha = 1
            } else {
                self.viewWithTag(999)?.alpha = 0
            }
        })
        
    }
    


    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation. */
    
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        if self.placeholderText != nil {
            if self.placeholderLabel == nil {
                placeholderLabel = UILabel(frame: CGRectMake(0,8,self.bounds.size.width,0))
                placeholderLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                placeholderLabel?.numberOfLines = 0
                placeholderLabel?.font = self.font
                placeholderLabel?.backgroundColor = UIColor.clearColor()
                placeholderLabel?.textColor = self.placeholderColor
                placeholderLabel?.alpha = 0
                placeholderLabel?.tag = 999
                
                self.addSubview(placeholderLabel!)
                LogError.log("Created Label")
            }
            placeholderLabel?.text = placeholderText
            placeholderLabel?.sizeToFit()
            self.sendSubviewToBack(placeholderLabel!)
            LogError.log("Value os self.text is \(self.text)")

            
            
            if self.text == "" {
                LogError.log("Setting alpha to 1")
                self.viewWithTag(999)?.alpha = 1
            }
        }
        
        super.drawRect(rect)
    }
    
}
