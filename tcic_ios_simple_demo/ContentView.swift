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
        headerConfig.showQuitButton = true;
        headerConfig.showLeftQuitButton = false;
        headerConfig.portraitHeaderLayout = 0;
        
        let mainViewBuilderJson = "{\n" +
        "  \"widget\": \"Box\",\n" +
        "  \"padding\": 16,\n" +
        "  \"backgroundImage\": {\n" +
        "    \"src\": \"https://tcic-prod-1257307760.qcloudclass.com/doc/gqc7lpugu87e0sruvl2d_tiw/thumbnail/1.jpg\",\n" +
        "    \"fit\": \"fill\"\n" +
        "  },\n" +
        "  \"child\": {\n" +
        "    \"widget\": \"Center\",\n" +
        "    \"child\": {\n" +
        "      \"widget\": \"Column\",\n" +
        "      \"gap\": 18,\n" +
        "      \"align\": \"center\",\n" +
        "      \"mainAxisSize\": \"min\",\n" +
        "      \"crossAlign\": \"center\",\n" +
        "      \"children\": [\n" +
        "        {\n" +
        "          \"widget\": \"Text\",\n" +
        "          \"fontSize\": 18,\n" +
        "          \"text\": \"老师：小张\",\n" +
        "          \"color\": \"#D9FFFFFF\"\n" +
        "        },\n" +
        "        {\n" +
        "          \"widget\": \"Text\",\n" +
        "          \"fontSize\": 16,\n" +
        "          \"color\": \"#D9FFFFFF\",\n" +
        "          \"text\": \"腾讯云互动课堂测试\"\n" +
        "        },\n" +
        "        {\n" +
        "          \"widget\": \"Text\",\n" +
        "          \"fontSize\": 14,\n" +
        "          \"color\": \"#D9FFFFFF\",\n" +
        "          \"text\": \"上课时间: 121312313\"\n" +
        "        }\n" +
        "      ]\n" +
        "    }\n" +
        "  }\n" +
        "}";
        
        let mainViewComponetConfig = TCICMainViewComponentConfig();
        mainViewComponetConfig.builderJson = mainViewBuilderJson;
        
        let basicConfig = TCICBasicConfig(
            autoStartClass: false, allowEarlyEnter: false,
            allowPipMode: true
        );
        basicConfig.teacherVideoFloating = false;
        
        let footerComponentConfig =  TCICFooterComponentConfig();
        let footerBuilderJson = "{\n" +
                       "  \"widget\": \"Row\",\n" +
                       "  \"crossAlign\": \"end\",\n" +
                       "  \"children\": [\n" +
                       "    {\n" +
                       "      \"widget\": \"Slot\",\n" +
                       "      \"name\": \"footer\"\n" +
                       "    },\n" +
                       "    {\n" +
                       "      \"widget\": \"SizedBox\",\n" +
                       "      \"width\": 10\n" +
                       "    },\n" +
                       "    {\n" +
                       "      \"widget\": \"Box\",\n" +
                       "      \"width\": 35,\n" +
                       "      \"height\": 35,\n" +
                       "      \"corners\": 8,\n" +
                       "      \"background\": \"#1C2333\",\n" +
                       "      \"alignment\": \"center\",\n" +
                       "      \"child\": {\n" +
                       "        \"widget\": \"Touchable\",\n" +
                       "        \"id\": \"node_1769156273090_692060913\",\n" +
                       "        \"onClick\": \"switchLayoutOrientation\",\n" +
                       "        \"child\": {\n" +
                       "          \"widget\": \"Icon\",\n" +
                       "          \"icon\": \"screen_rotation_rounded\",\n" +
                       "          \"size\": 20,\n" +
                       "          \"color\": \"#FFFFFF\"\n" +
                       "        }\n" +
                       "      }\n" +
                       "    },\n" +
                       "    {\n" +
                       "      \"widget\": \"SizedBox\",\n" +
                       "      \"width\": 10\n" +
                       "    }\n" +
                       "  ]\n" +
        "}";
        footerComponentConfig.footerBuilderJson = footerBuilderJson;
        
        let membersComponentConfig = TCICMembersComponentConfig();
        membersComponentConfig.teacherRoleBackgroundColor = "#ff0000";
        
        let config = TCICConfig(
            token: params["token"] as! String,
            classId: params["classid"] as! String,
            userId: params["userid"] as! String,
            role: 1,
            headerComponentConfig: headerConfig, 
            basicConfig: basicConfig,
            membersComponentConfig: membersComponentConfig, footerComponentConfig: footerComponentConfig, mainViewComponentConfig: mainViewComponetConfig
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
