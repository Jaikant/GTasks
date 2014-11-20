//
//  DatePickerController.swift
//  GTasks
//
//  Created by Jai on 07/11/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController {
    
    var datePicker = UIDatePicker()
    
    var dateLabel = UILabel()
    
    /// A date formatter to format the `date` property of `datePicker`.
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter
        }()


    
    override init() {
        super.init()

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
        
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        
        datePicker.userInteractionEnabled = true
        
        
        let now = NSDate()
        LogError.log("Now is: \(now)")
        
        let currentCalendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        
        datePicker.locale = NSLocale.currentLocale()
        datePicker.date = now
        datePicker.calendar = currentCalendar
        
        dateComponents.day = 365
        
        let oneYearFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        datePicker.maximumDate = oneYearFromNow
        
        
        datePicker.addTarget(self, action: "updateDatePickerLabel", forControlEvents: .ValueChanged)
        datePicker.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var pickerSize = datePicker.sizeThatFits(CGSizeZero)
        var pickerTransformView = UIView(frame: CGRectMake(0, 0, pickerSize.width, pickerSize.height))
        //pickerTransformView.addSubview(datePicker)
        //pickerTransformView.frame.origin = CGPoint(x: (self.view.bounds.width - pickerTransformView.frame.width)/2, y: self.view.bounds.minY + 5)
        pickerTransformView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        
        var origin = CGPoint(x: pickerTransformView.frame.minX + 40, y: pickerTransformView.frame.maxY + 20)

        dateLabel.frame = CGRect(origin: origin, size: CGSizeMake(self.view.bounds.width * 0.8, 40))
        
        
        dateLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
        view.transform = CGAffineTransformMakeScale(0.80, 0.80)
        
        dateLabel.text = "Date: " + dateFormatter.stringFromDate(datePicker.date)
        
        //pickerTransformView.layer.cornerRadius = 5.0
        //pickerTransformView.layer.borderWidth = 1.0;
        //pickerTransformView.layer.borderColor = UIColor.lightGrayColor().CGColor;

        datePicker.layer.cornerRadius = 5.0
        //self.view.addSubview(pickerTransformView)
        self.view.addSubview(datePicker)

        self.view.addSubview(dateLabel)
        LogError.log("Init complete")
        
        //Debugging only
        self.view.backgroundColor = UIColor.whiteColor()
        //pickerTransformView.backgroundColor = UIColor.redColor()
        //datePicker.backgroundColor = UIColor.lightGrayColor()
        //datePicker.alpha = 0.9
        
        
        
        // Select button
        var frame =  CGRect(origin: CGPoint(x: CGRectGetMaxX(self.view.bounds)*0.1, y: CGRectGetMaxY(self.view.bounds)*0.7), size: CGSize(width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.1))
        
        var selectButton = UIButton(frame: frame)
        configureAttributedTextSystemButton(selectButton)
        selectButton.backgroundColor = UIColor.redColor()

        selectButton.transform = CGAffineTransformMakeScale(1.25, 1.25)
        //selectButton.layer.cornerRadius = 5.0
        selectButton.backgroundColor = UIColor.lightGrayColor()

        self.view.addSubview(selectButton)


    
        
    }

    func updateDatePickerLabel() {
        dateLabel.text = "Date: " + dateFormatter.stringFromDate(datePicker.date)
        LogError.log("Date picked: \(dateLabel.text)")
        reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureAttributedTextSystemButton(attributedTextButton: UIButton) {
        let buttonTitle = NSLocalizedString("Select", comment: "")
        
        // Set the button's title for normal state.
        let normalTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.applicationBlueColor()
        ]
        let normalAttributedTitle = NSAttributedString(string: buttonTitle, attributes: normalTitleAttributes)
        attributedTextButton.setAttributedTitle(normalAttributedTitle, forState: .Normal)
        
        // Set the button's title for highlighted state.
        let highlightedTitleAttributes = [
            NSForegroundColorAttributeName: UIColor.greenColor(),
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleThick.rawValue
        ]
        let highlightedAttributedTitle = NSAttributedString(string: buttonTitle, attributes: highlightedTitleAttributes)
        attributedTextButton.setAttributedTitle(highlightedAttributedTitle, forState: .Highlighted)
        
        attributedTextButton.addTarget(self, action: "selectDate", forControlEvents: .TouchUpInside)
    }
    

    func selectDate() {
        dismissViewControllerAnimated(true, completion: {})
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
