//
//  MyHeaderLeftView.swift
//  tcic_ios_simple_demo
//
//  Created by joyxian on 2025/8/27.
//

import Foundation
import UIKit
import tcic_ios
import Flutter

class MyHeaderLeftView: TCICViewFactory {
    override init(messenger: FlutterBinaryMessenger) {
        super.init(messenger: messenger)
    }
    override func createNativeView(frame: CGRect, viewId: Int64, args: Any?) -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = .blue


        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 48))
        label.text = "My Header Left View From Ios"
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)


        return view
    }
}

