//  ContentView.swift

import SwiftUI
import WebKit
import tcic_ios

// 实现 UIEventCallback 协议
class TCICUIEventHandler: UIEventCallback {
    var onSwitchLayoutOrientation: (() -> Void)?
    
    func onUIEvent(eventName: String, widgetId: String?, data: [String: Any]) {
        print("Received UI Event: \(eventName), widgetId: \(widgetId ?? "nil")")
        
        if eventName == "switchLayoutOrientation" {
            onSwitchLayoutOrientation?()
        }
    }
}

struct ContentView: View {
    @State private var callback: TCICCallback = TCICCallback()
    @State private var uiEventHandler = TCICUIEventHandler()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 使用引导页面替代WebView
                ClassroomSetupWizardView { classroomInfo in
                    handleGotoRoomPage(classroomInfo: classroomInfo)
                }
                

                .onAppear {
                    // 初始化 TCICManager
                    self.callback.afterExitedClassBlock = {
                        print("afterExitedClass called - page will auto close")
                    }
                    self.callback.onJoinedClassFailedBlock = {
                        print("joined class failed")
                    }
                    self.callback.onClassStartedBlock = {
                        print("class started");
                        TCICManager.shared.updateMainViewComponentConfig(nil);
                    }
                    
                    // 设置 UI 事件回调，监听按钮点击
                    uiEventHandler.onSwitchLayoutOrientation = {
                        print("switchLayoutOrientation button clicked!")
                        // 调用 SDK 方法切换横竖屏
                        TCICManager.shared.switchLayoutOrientation()
                    }
                    TCICManager.shared.setUIEventCallback(uiEventHandler)
                    
                    TCICManager.shared.setCallback(callback)
                }
            }
        }
    }
    
    private func handleGotoRoomPage(classroomInfo: ClassroomInfo) {
        // 将ClassroomInfo转换为参数字典
        let params: [String: Any] = [
            "token": classroomInfo.token,
            "classid": classroomInfo.roomId,
            "userid": classroomInfo.userId,
            "role": "teacher" // 默认设置为teacher，你可以根据需要修改
        ]
        
        let headerConfig = TCICHeaderComponentConfig();
        headerConfig.showClassLogo = true;
        headerConfig.showNetworkStatus = false;
        headerConfig.showClassInfo = false;
        headerConfig.showQuitButton = false;
        headerConfig.showLeftQuitButton = true;
        headerConfig.portraitHeaderLayout = 0;
        
        let mainViewBuilderJson = """
{
  "widget": "SizedBox",
  "expand": true,
  "child": {
    "widget": "Stack",
    "children": [
      {
        "widget": "Positioned",
        "fill": true,
        "child": {
          "widget": "Box",
          "background": {
            "gradient": {
              "begin": "topLeft",
              "end": "bottomRight",
              "colors": ["#0B4DFF", "#6A5CFF", "#0BC6FF"]
            }
          }
        }
      },
      {
        "widget": "Positioned",
        "fill": true,
        "child": {
          "widget": "Opacity",
          "opacity": 0.22,
          "child": {
            "widget": "Image",
            "src": "https://tcic-prod-1257307760.qcloudclass.com/doc/gqc7lpugu87e0sruvl2d_tiw/thumbnail/1.jpg",
            "fit": "cover"
          }
        }
      },
      {
        "widget": "Positioned",
        "fill": true,
        "child": {
          "widget": "Box",
          "background": "rgba(0,0,0,0.30)"
        }
      },
      {
        "widget": "Positioned",
        "fill": true,
        "child": {
          "widget": "SafeArea",
          "child": {
            "widget": "Center",
            "child": {
              "widget": "Padding",
              "padding": { "horizontal": 24 },
              "child": {
                "widget": "Column",
                "mainAxisSize": "min",
                "align": "center",
                "crossAlign": "center",
                "gap": 18,
                "children": [
                  {
                    "widget": "Text",
                    "text": "课堂名称",
                    "textAlign": "center",
                    "maxLines": 2,
                    "overflow": "ellipsis",
                    "fontSize": 26,
                    "fontWeight": "w800",
                    "color": "#FFFFFF"
                  },
                  {
                    "widget": "Text",
                    "text": "老师：老师名称",
                    "textAlign": "center",
                    "maxLines": 1,
                    "overflow": "ellipsis",
                    "fontSize": 16,
                    "fontWeight": "w600",
                    "color": "rgba(255,255,255,0.92)"
                  },
                  {
                    "widget": "Text",
                    "text": "上课时间：2026-02-11 10:00",
                    "textAlign": "center",
                    "maxLines": 1,
                    "overflow": "ellipsis",
                    "fontSize": 14,
                    "fontWeight": "w600",
                    "color": "rgba(255,255,255,0.85)"
                  }
                ]
              }
            }
          }
        }
      }
    ]
  }
}
""";
        
        let mainViewComponetConfig = TCICMainViewComponentConfig();
//        mainViewComponetConfig.builderJson = mainViewBuilderJson;
        mainViewComponetConfig.mainViewBuilder = {
                   return MainViewNativeViewCreator(messenger: TCICManager.shared.Tengine!.binaryMessenger)
               }
        
        let basicConfig = TCICBasicConfig(
            autoStartClass: false, allowEarlyEnter: true,
            allowPipMode: false
        );
        basicConfig.teacherVideoFloating = true;
        
        
        let membersComponentConfig = TCICMembersComponentConfig();
        membersComponentConfig.teacherRoleBackgroundColor = "#ff0000";
        
        let config = TCICConfig(
            token: params["token"] as! String,
            classId: params["classid"] as! String,
            userId: params["userid"] as! String,
            headerComponentConfig: headerConfig, 
            basicConfig: basicConfig,
            membersComponentConfig: membersComponentConfig,  mainViewComponentConfig: mainViewComponetConfig
        );
        
        TCICManager.shared.setConfig(config)
        
        // 获取当前 UIViewController 来调用 openTCICPage
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            TCICManager.shared.openTCICPage(from: rootVC)
        }
    }
}

#Preview {
    ContentView()
}
