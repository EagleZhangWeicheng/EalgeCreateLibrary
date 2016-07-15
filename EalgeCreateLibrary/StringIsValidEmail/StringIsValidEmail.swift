//
//  StringIsValidEmail.swift
//  ZhaiDou
//
//  Created by eagle on 14/12/11.
//  Copyright (c) 2014年 Eagle. All rights reserved.
//

import UIKit

extension String{
    //判断是否是邮件地址
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}