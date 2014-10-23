//
//  TaskListPickerTableViewCell.swift
//  GTasks
//
//  Created by Jai on 13/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TaskListPickerTableViewCell: UITableViewCell {
    
    
    var pkrvw = UIPickerView()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var cellbnds = self.contentView.bounds
        var contsize = pkrvw.sizeThatFits(CGSizeZero)
        var pkrvwcontainer = UIView()

        pkrvwcontainer.frame = CGRectMake(0, 0, contsize.width, contsize.height)
        pkrvwcontainer.addSubview(pkrvw)
        pkrvwcontainer.transform = CGAffineTransformMakeScale(0.60, 0.60)
        pkrvwcontainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //The frame x axis is such that there is equal spacing for the right and left margins
        pkrvwcontainer.frame.origin = CGPoint(x: (cellbnds.width - pkrvwcontainer.frame.width)/2, y: 0)
       
        
        self.contentView.addSubview(pkrvwcontainer)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        pkrvw.showsSelectionIndicator = true
        
        /*
        LogError.log("cell bounds: \(cell.bounds)")
        LogError.log("ContentView bounds: \(cell.contentView.bounds)")
        LogError.log("Container View bounds: \(pkrvwcontainer.bounds)")
        LogError.log("Picker View bounds: \(pkrvw.bounds)")
        
        LogError.log("cell frame: \(cell.contentView.frame)")
        LogError.log("ContentView frame: \(cell.contentView.frame)")
        LogError.log("Container View frame: \(pkrvwcontainer.frame)")
        LogError.log("Picker View frame: \(pkrvw.frame)")
        
        LogError.log("cell subview: \(cell.subviews)") */
    
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }

}
