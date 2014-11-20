//
//  StatusTableViewCell.swift
//  GTasks
//
//  Created by Jai on 14/10/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    var lbl = UILabel()
    var stabut : UIButton?
    var statusImage : UIImage = UIImage(named: "4-grey.png")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var cellbnds = self.contentView.bounds
        
        lbl = UILabel(frame: CGRectMake(cellbnds.minX + 15, cellbnds.minY, cellbnds.width - 50, cellbnds.height))
        lbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.contentView.addSubview(lbl)
        
        stabut = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        stabut?.setImage(statusImage, forState: UIControlState.Normal)
        stabut?.sizeToFit()
        stabut?.frame.origin = CGPoint(x: cellbnds.maxX - 80, y: cellbnds.minY)
        stabut?.transform = CGAffineTransformMakeScale(0.60, 0.60)
        
        self.contentView.addSubview(stabut!)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .None
        // Configure the view for the selected state
    }

}
