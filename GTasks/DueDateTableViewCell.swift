//
//  DueDateTableViewCell.swift
//  GTasks
//
//  Created by Jai on 12/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class DueDateTableViewCell: UITableViewCell {
    
    var datePicker = UIDatePicker()
    
    var dateLabel = UILabel()
    
    /// A date formatter to format the `date` property of `datePicker`.
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter
        }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //datePicker.restorationIdentifier = "datePicker"
        
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
        pickerTransformView.transform = CGAffineTransformMakeScale(0.60,0.60)
        pickerTransformView.addSubview(datePicker)
        pickerTransformView.frame.origin = CGPoint(x: (self.contentView.bounds.width - pickerTransformView.frame.width)/2, y: 0)
        pickerTransformView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //datePicker?.bounds.origin = CGPoint(x: 0, y: 44)
        //contentView.frame.size = CGSizeMake(320, 216)
        
        
        
        self.contentView.addSubview(pickerTransformView)
        //self.contentView.bringSubviewToFront(pickerTransformView)
        //if the below does not work, try the same on the sub views.
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        self.contentView.addSubview(dateLabel)
        var pickerbnds = pickerTransformView.frame
        dateLabel.frame = CGRect(origin: CGPoint(x: CGRectGetMinX(pickerbnds) + 10, y: CGRectGetMaxY(pickerbnds)) , size: CGSize(width: pickerbnds.width - 10, height: 20))
        dateLabel.textAlignment = NSTextAlignment.Center
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }
    
    
    func updateDatePickerLabel() {
        dateLabel.text = dateFormatter.stringFromDate(datePicker.date)
        dateLabel.textColor = UIColor.redColor()
        LogError.log("Date picked: \(dateLabel.text)")
    }


}
