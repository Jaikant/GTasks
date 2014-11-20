//
//  TasksDetailViewCell.swift
//  GTasks
//
//  Created by Jai on 09/11/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import Foundation
//
//  TasksTableViewCell.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TasksDetailViewCell: UITableViewCell {
    
    //Label
    var lbl = UILabel()

    // Edit Icon Button
    var iconBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "TasksDetail")
        
        self.contentView.addSubview(lbl)
        self.lbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.lbl.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.lbl.numberOfLines = 0
        
        
        iconBut.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(iconBut)
        
        
        //Setup the cell constraints
        var viewlist = NSMutableDictionary()
        viewlist.setValue(lbl, forKey: "lbl")
        viewlist.setValue(iconBut, forKey: "iconBut")
        
        var h_cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[lbl]-[iconBut(30)]-5-|", options: nil, metrics: nil, views: viewlist)
        
        var v_lbl_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[lbl]-5-|", options: nil, metrics: nil, views: viewlist)
        
        var v_icon_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-==10-[iconBut(15)]->=10-|", options: nil, metrics: nil, views: viewlist)
        
        contentView.addConstraints(h_cons)
        contentView.addConstraints(v_lbl_cons)
        contentView.addConstraints(v_icon_cons)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
