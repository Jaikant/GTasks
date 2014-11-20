//
//  TasksTableViewCell.swift
//  GTasks
//
//  Created by Jai on 19/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import UIKit

class TasksTableViewCell: RMSwipeTableViewCell {
    
    var lbl = UILabel()
    var sublbl = UILabel()

    
    // First button which is the delete button
    var firstImgGreyBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var firstImgRedBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var firstImgGrey = UIImage(named: "1-grey.png")
    var firstImgRed = UIImage(named: "1-red.png")

    
    
    var secondImgGreyBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var secondImgRedBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var secondImgGrey = UIImage(named: "calendar.png")
    var secondImgRed = UIImage(named: "calendar-red.png")

    
    
    var statusImgGreyBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var statusImgGreenBut = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
    var statusImgGrey = UIImage(named: "4-grey.png")
    var statusImgGreen = UIImage(named: "4-green.png")


    var syncStatusImageView = UIImageView(image: UIImage(named: "syncFalse.png"))

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
        super.init(style: style, reuseIdentifier: "cellTask")
        
        self.contentView.addSubview(lbl)
        self.lbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.lbl.numberOfLines = 2
        self.lbl.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        self.contentView.addSubview(sublbl)
        self.sublbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        self.sublbl.numberOfLines = 2
        self.sublbl.setTranslatesAutoresizingMaskIntoConstraints(false)

    
        
        //add first delete button
        
        //configure the button
        firstImgGreyBut.setImage(firstImgGrey, forState: UIControlState.Normal)
        firstImgGreyBut.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //configure the button
        firstImgRedBut.setImage(firstImgRed, forState: UIControlState.Normal)
        firstImgRedBut.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //populate the view
        self.contentView.addSubview(firstImgGreyBut)
        
        
        
        //add second calendar button
        secondImgGreyBut.setImage(secondImgGrey, forState: UIControlState.Normal)
        secondImgGreyBut.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        secondImgRedBut.setImage(secondImgRed, forState: UIControlState.Normal)
        secondImgRedBut.setTranslatesAutoresizingMaskIntoConstraints(false)

        //Populate the view
        self.contentView.addSubview(secondImgGreyBut)
        
        
        //add a button
        statusImgGreyBut.setImage(statusImgGrey, forState: UIControlState.Normal)
        statusImgGreyBut.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        statusImgGreenBut.setImage(statusImgGreen, forState: UIControlState.Normal)
        statusImgGreenBut.setTranslatesAutoresizingMaskIntoConstraints(false)

        //Populate the view
        self.contentView.addSubview(statusImgGreyBut)
        
        
        //Add the sync status imageview to the cell
        syncStatusImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(syncStatusImageView)

        
        
        
        //Setup the cell constraints
        var viewlist = NSMutableDictionary()
        viewlist.setValue(lbl, forKey: "label")
        viewlist.setValue(sublbl, forKey: "sublbl")

        viewlist.setValue(firstImgGreyBut, forKey: "firstImgGreyBut")
        viewlist.setValue(secondImgGreyBut, forKey: "secondImgGreyBut")
        viewlist.setValue(statusImgGreyBut, forKey: "statusImgGreyBut")
        viewlist.setValue(syncStatusImageView, forKey: "syncStatusImageView")


        
        var h_cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[syncStatusImageView(10)]-[label]-5-|", options: nil, metrics: nil, views: viewlist)
        
        var h_cons_lbl = NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[sublbl]-5-|", options: nil, metrics: nil, views: viewlist)

        var h_img_cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[firstImgGreyBut(20)]-80-[secondImgGreyBut(20)]-80-[statusImgGreyBut(20)]->=20-|", options: nil, metrics: nil, views: viewlist)
        
        var v_firstImg_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-[sublbl]-15-[firstImgGreyBut(10)]-5-|", options: nil, metrics: nil, views: viewlist)
        
        var v_secondImg_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-[sublbl]-15-[secondImgGreyBut(10)]-5-|", options: nil, metrics: nil, views: viewlist)

        var v_statusImgGrey_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-[sublbl]-15-[statusImgGreyBut(10)]-5-|", options: nil, metrics: nil, views: viewlist)
        
        var v_syncStatusImageView_cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[syncStatusImageView(10)]->=15-|", options: nil, metrics: nil, views: viewlist)


        contentView.addConstraints(h_cons)
        contentView.addConstraints(h_cons_lbl)
        contentView.addConstraints(h_img_cons)
        contentView.addConstraints(v_firstImg_cons)
        contentView.addConstraints(v_secondImg_cons)
        contentView.addConstraints(v_statusImgGrey_cons)
        contentView.addConstraints(v_syncStatusImageView_cons)

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
