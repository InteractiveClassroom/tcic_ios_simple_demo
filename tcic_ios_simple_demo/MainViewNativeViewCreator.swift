//
//  MainViewNativeViewCreator.swift
//  tcic_client_ios
//
//  MainView 自定义 Native View 实现
//  显示课程封面、老师信息、课程名称、上课时间
//

import UIKit
import Flutter
import tcic_ios

class MainViewNativeViewCreator: TCICViewFactory {
    
    override func createNativeView(frame: CGRect, viewId: Int64, args: Any?) -> UIView {
        let rootView = UIView(frame: frame)
        rootView.backgroundColor = UIColor(hex: "#333333")
        
        // 背景图
        let backgroundImageView = UIImageView(frame: rootView.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.isUserInteractionEnabled = false
        rootView.addSubview(backgroundImageView)
        
        // 异步加载网络图片
        loadImage(from: "https://tcic-prod-1257307760.qcloudclass.com/doc/gqc7lpugu87e0sruvl2d_tiw/thumbnail/1.jpg", into: backgroundImageView)
        
        // 半透明遮罩层
        let overlayView = UIView(frame: rootView.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.isUserInteractionEnabled = false
        rootView.addSubview(overlayView)
        
        // 内容容器
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isUserInteractionEnabled = false
        rootView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: rootView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: rootView.trailingAnchor, constant: -16)
        ])
        
        // 老师名称
        let teacherLabel = createLabel(text: "老师：小张22333", fontSize: 18, color: UIColor.white.withAlphaComponent(0.85))
        contentStack.addArrangedSubview(teacherLabel)
        
        // 课程名称
        let courseLabel = createLabel(text: "腾讯云互动课堂测试", fontSize: 16, color: UIColor.white.withAlphaComponent(0.85))
        contentStack.addArrangedSubview(courseLabel)
        
        // 上课时间
        let timeLabel = createLabel(text: "上课时间: 121312313", fontSize: 14, color: UIColor.white.withAlphaComponent(0.85))
        contentStack.addArrangedSubview(timeLabel)
        
        // 不拦截触摸事件，让 Flutter 处理
        rootView.isUserInteractionEnabled = false
        
        return rootView
    }
    
    private func createLabel(text: String, fontSize: CGFloat, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = color
        label.textAlignment = .center
        return label
    }
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}

// MARK: - UIColor Hex 扩展
private extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
