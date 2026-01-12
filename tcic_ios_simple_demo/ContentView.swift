//  ContentView.swift

import SwiftUI
import WebKit
import tcic_ios

struct ContentView: View {
    @State private var callback: TCICCallback = TCICCallback()
    @State private var isGotoRoomPageActive: Bool = false
    @State private var roomPageParams: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 使用引导页面替代WebView
                ClassroomSetupWizardView { classroomInfo in
                    handleGotoRoomPage(classroomInfo: classroomInfo)
                }
                
                NavigationLink(
                    destination: TPageWrapper(params: roomPageParams),
                    isActive: $isGotoRoomPageActive,
                    label: { EmptyView() }
                )
                .hidden()
                .onChange(of: isGotoRoomPageActive) { newValue in
                    if !newValue {
                        TCICManager.shared.Tengine.viewController = nil
                    }
                }
                .onAppear {
                    // 初始化 TCICManager
                    self.callback.afterExitedClassBlock = {
                        print("dismiss page")
                        isGotoRoomPageActive = false
                        TCICManager.shared.Tengine.viewController = nil
                    }
                    self.callback.onJoinedClassFailedBlock = {
                        print("joined class failed")
                        isGotoRoomPageActive = false
                        TCICManager.shared.Tengine.viewController = nil
                    }
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
        
        let role = params["role"] as! String
        
        let headerConfig = TCICHeaderComponentConfig()
        
        let headerLeftBuilder: TCICHeaderComponentConfig.HeaderBuilder = {
            return MyHeaderLeftView(messenger: TCICManager.shared.Tengine.binaryMessenger)
        }
        headerConfig.headerLeftBuilder = headerLeftBuilder
        headerConfig.headerLeftBuilderWidth = 200
        headerConfig.headerLeftBuilderHeight = 40
        
        let basicConfig = TCICBasicConfig(
            autoStartClass: true, allowEarlyEnter: true,
            allowPipMode: true
        );
        
        let layoutConfig = TCICLayoutConfig(landscapeLayoutConfig: LandscapeLayoutConfig(memberListPosition: TLayoutPosition.right))
    
        // let boardConfig = TCICBoardConfig(boardStreamConfig: BoardStreamConfig(boardStreamUrl: ""))
        
        let config = TCICConfig(
            token: params["token"] as! String,
            classId: params["classid"] as! String,
            userId: params["userid"] as! String,
            role: 1
            // basicConfig: basicConfig,
            // layoutConfig: layoutConfig
            // boardConfig: boardConfig
        )
        
        TCICManager.shared.setConfig(config)
        
        // 保存参数并触发跳转
        self.roomPageParams = params
        self.isGotoRoomPageActive = true
    }
}

struct TPageWrapper: View {
    let params: [String: Any]

    var body: some View {
        TCICManager.TPage()
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
}
