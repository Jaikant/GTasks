//
//  TaskListsTableViewCell.swift
//  GTasks
//
//  Created by Jai on 18/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TaskListsTableViewCell: RMSwipeTableViewCell {
    
    lazy var editGreyImageView : UIImageView? = {
        var _editGreyImageView : UIImageView? = UIImageView(frame: CGRectMake(0, 0, CGRectGetHeight(self.contentView.frame), CGRectGetHeight(self.contentView.frame)))
            _editGreyImageView?.image = UIImage(named: "icon-edit-grey-50.png")
            self.backView.addSubview(_editGreyImageView!)
            return _editGreyImageView?
    }()
    
    lazy var editGreenImageView : UIImageView? = {
        var _editGreenImageView : UIImageView? = UIImageView(frame: CGRectMake(0, 0, CGRectGetHeight(self.contentView.frame), CGRectGetHeight(self.contentView.frame)))
        _editGreenImageView?.image = UIImage(named: "icon-edit-green-50.png")
        self.editGreyImageView?.addSubview(_editGreenImageView!)
        return _editGreenImageView?
        }()
    
    lazy var deleteGreyImageView : UIImageView? = {
        var _deleteGreyImageView : UIImageView? = UIImageView(frame: CGRectMake(0, 0, CGRectGetHeight(self.contentView.frame), CGRectGetHeight(self.contentView.frame)))
        _deleteGreyImageView?.image = UIImage(named: "icon-delete-gray-50.png")
        self.backView.addSubview(_deleteGreyImageView!)
        return _deleteGreyImageView?
        }()

    
    lazy var deleteRedImageView : UIImageView? = {
        var _deleteRedImageView : UIImageView? = UIImageView(frame: CGRectMake(0, 0, CGRectGetHeight(self.contentView.frame), CGRectGetHeight(self.contentView.frame)))
        _deleteRedImageView?.image = UIImage(named: "icon-delete-red-50.png")
        self.deleteGreyImageView?.addSubview(_deleteRedImageView!)
        return _deleteRedImageView?
        }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tasklists")
        
        self.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedBackgroundView.alpha = 0.2
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }
    
    
    override func animateContentViewForPoint(point: CGPoint, velocity: CGPoint) {
        super.animateContentViewForPoint(point, velocity: velocity)
        if (point.x > 0)  {
            var xVal:CGFloat = CGRectGetMinX(self.contentView.frame) - CGRectGetWidth(self.editGreyImageView!.frame)
            if xVal > 0 {
                xVal = 0
            }
            self.editGreyImageView?.frame = CGRectMake(xVal, CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.editGreyImageView!.frame), CGRectGetHeight(self.editGreyImageView!.frame))
            if point.x > CGRectGetHeight(self.contentView.frame) {
                self.editGreenImageView?.alpha = 1.0
            } else {
                self.editGreenImageView?.alpha = 0.0

            }
        } else {
            var xValDel : CGFloat = CGRectGetMaxX(self.contentView.frame)
            self.deleteGreyImageView?.frame = CGRectMake(xValDel, CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.deleteGreyImageView!.frame), CGRectGetHeight(self.deleteGreyImageView!.frame))
            if -point.x > CGRectGetWidth(self.deleteGreyImageView!.frame) {
                self.deleteRedImageView?.alpha = 1.0
            } else {
                self.deleteRedImageView?.alpha = 0.0
            }
        }
        
    }
}
