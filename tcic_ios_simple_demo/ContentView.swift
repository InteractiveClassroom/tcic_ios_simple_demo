//
//  ContentView.swift
//  tcic_ios_simple_demo
//
//  Created by joyxian on 2025/8/27.
//

import SwiftUI
import WebKit
import tcic_ios

// 定义接口协议，支持两个方法
protocol WebViewHandler: AnyObject {
    func handleGotoRoomPage(params: [String: Any])
}

// WKWebView封装，支持接收JS消息
struct WebView: UIViewRepresentable {
    let url: URL
    let handler: WebViewHandler
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 注册消息监听器
        userContentController.add(context.coordinator, name: "gotoRoomPage")
        
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, handler: handler)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: WebView
        let handler: WebViewHandler
        
        init(_ parent: WebView, handler: WebViewHandler) {
            self.parent = parent
            self.handler = handler
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gotoRoomPage" {
                if let params = message.body as? [String: Any] {
                    handler.handleGotoRoomPage(params: params)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView didFinish navigation")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView didFail navigation: \(error.localizedDescription)")
        }
    }
}

// 实现 WebViewHandler 协议
class WebViewHandlerImpl: NSObject, ObservableObject, WebViewHandler {
    @Published var message: String?
    
    // 控制跳转状态
    @Published var isGotoRoomPageActive: Bool = false
    
    // 保存传递的参数
    var roomPageParams: [String: Any]?
    
    
    func handleGotoRoomPage(params: [String: Any]) {
        self.roomPageParams = params
        var paramString = "接收到gotoHome调用，参数："
        for (key, value) in params {
            paramString += "\n\(key): \(value)"
        }
        let role = params["role"] as! String;
        
        let headerConfig = TCICHeaderComponentConfig();

        let headerLeftBuilder: TCICHeaderComponentConfig.HeaderBuilder = {
            return MyHeaderLeftView(messenger: TCICManager.shared.Tengine.binaryMessenger);
        }
        headerConfig.headerLeftBuilder = headerLeftBuilder; // builder
        headerConfig.headerLeftBuilderWidth = 200; // 宽
        headerConfig.headerLeftBuilderHeight = 40 // 高
        
        let config = TCICConfig(
            token: params["token"] as! String, /// 通过云API获取的token
            classId: params["classid"] as! String, /// 课堂id
            userId: params["userid"] as! String, /// 用户userId
            role: role == "student" ?  0 : (role == "teacher" ? 1 : (role == "assistant" ? 3 : 4)), /// 用户角色，0: 学生,1: 老师, 3: 助教, 4: 巡课
            headerComponentConfig: headerConfig
           );


        TCICManager.shared.setConfig(config);
        self.isGotoRoomPageActive = true
    }
}

struct TPageWrapper: View {
    let params: [String: Any]

    var body: some View {
        TCICManager.TPage()
            .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

// 主内容视图
struct ContentView: View {
    @State private var isActive = false;
    @State private var callback: TCICCallback = TCICCallback() // 添加这一行

    let webViewURL = URL(string: "https://dev-class.qcloudclass.com/flutter/login.html?lng=zh")!
    
    @StateObject private var webViewHandler = WebViewHandlerImpl()
    
    var body: some View {
        NavigationView {
            ZStack {
                WebView(url: webViewURL, handler: webViewHandler)
                    .edgesIgnoringSafeArea(.all)
            
                
               NavigationLink(
                   destination: TPageWrapper(params: webViewHandler.roomPageParams ?? [:]),
                   isActive: $webViewHandler.isGotoRoomPageActive,
                   label: { EmptyView() }
               )
               .hidden()
               .onChange(of: webViewHandler.isGotoRoomPageActive) { newValue in
                   if !newValue {
                       TCICManager.shared.Tengine.viewController = nil
                   }
               }.onAppear {
                   // 初始化 TCICManager
                   self.callback.afterExitedClassBlock = {
                       print("dismiss page");
                       webViewHandler.isGotoRoomPageActive = false;
                   }
                   self.callback.onJoinedClassFailedBlock = {
                       print("joined class failed");
                       webViewHandler.isGotoRoomPageActive = false;
                   }
                   TCICManager.shared.setCallback(callback);
               }
            }
        }
    }
}

#Preview {
    ContentView()
}
