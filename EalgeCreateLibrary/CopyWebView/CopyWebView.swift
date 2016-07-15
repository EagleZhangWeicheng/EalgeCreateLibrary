//
//  CopyWebView.swift
//  CopyLabel
//
//  Created by zhangweicheng on 7/15/16.
//  Copyright © 2016 zhaidou. All rights reserved.
//

import UIKit

class CopyWebView: UIWebView {
    var text = ""
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.attachTapHandler()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // 可以响应的方法
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(CopyLabel.copy(_:))
    }
    
    //针对于响应方法的实现
    override func copy(sender:AnyObject?) {
        let pborad = UIPasteboard.generalPasteboard()
        pborad.string = self.text
    }
    
    //UILabel默认是不接收事件的，我们需要自己添加touch事件
    func attachTapHandler() {
        self.userInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CopyLabel.longPress(_:)))
        self.addGestureRecognizer(longPress)
    }
    
    
    func longPress(longGesture:UILongPressGestureRecognizer)  {
        self.becomeFirstResponder()
        let copyLink = UIMenuItem(title: "复制", action: #selector(CopyLabel.copy(_:)))
        UIMenuController.sharedMenuController().menuItems = [copyLink]
        UIMenuController.sharedMenuController().setTargetRect(self.frame, inView: self.superview!)
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
    }


}
