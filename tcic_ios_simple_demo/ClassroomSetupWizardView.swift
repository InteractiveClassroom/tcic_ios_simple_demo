//  ClassroomSetupWizardView.swift

import SwiftUI
import SafariServices

struct ClassroomSetupWizardView: View {
    @StateObject private var stepStatus = WizardStepStatus()
    @State private var currentStepIndex = 0
    @State private var isProcessing = false
    @State private var classroomInfo: ClassroomInfo?
    @State private var classrooms: [RoomCreationResponse] = [] // 新增状态变量
    
    // 表单字段
    @State private var secretKey = UserDefaults.standard.string(forKey: "tcic_secretKey") ?? ""
    @State private var secretId = UserDefaults.standard.string(forKey: "tcic_secretId") ?? ""
    @State private var appId = UserDefaults.standard.string(forKey: "tcic_appId") ?? ""
    
    // 消息状态
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingResetAlert = false
    @State private var showingSafari = false
    
    // 跳转到课堂的回调
    let onEnterClassroom: (ClassroomInfo) -> Void
    
    private let totalSteps = 3
    private let documentationURL = "https://cloud.tencent.com/document/product/1639/79895#9b6257f6-95c7-4f5d-9eee-76edd86f80f7"
    
    init(onEnterClassroom: @escaping (ClassroomInfo) -> Void) {
        self.onEnterClassroom = onEnterClassroom
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    StepIndicatorView(
                        currentStep: currentStepIndex,
                        totalSteps: totalSteps,
                        stepStatus: stepStatus
                    )
                    
                    Spacer(minLength: 20)
                    
                    currentStepContent
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("课堂配置向导")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentStepIndex > 0 && !isProcessing {
                        Button {
                            showingResetAlert = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("确认重置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确定", role: .destructive) {
                resetWizard()
            }
        } message: {
            Text("这将清除所有配置信息并返回到第一步，确定要继续吗？")
        }
        .sheet(isPresented: $showingSafari) {
            if let url = URL(string: documentationURL) {
                SafariView(url: url)
            }
        }
    }
    
    @ViewBuilder
    private var currentStepContent: some View {
        switch currentStepIndex {
        case 0:
            configurationStep
        case 1:
            classroomCreationStep
        case 2:
            enterClassroomStep
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step 1: Configuration
    private var configurationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("步骤 1: 配置参数")
            
            Text("请从腾讯云控制台获取必要的信息并填写：")
                .font(.body)
            
            VStack(spacing: 16) {
                CustomTextField(
                    text: $secretKey,
                    placeholder: "腾讯云API Secret Key",
                    iconName: "key"
                )
                
                CustomTextField(
                    text: $secretId,
                    placeholder: "腾讯云API Secret ID",
                    iconName: "person.badge.key"
                )
                
                CustomTextField(
                    text: $appId,
                    placeholder: "互动课堂 App ID",
                    iconName: "apps.iphone"
                )
                .keyboardType(.numberPad)
            }
            
            PrimaryButton(
                title: "创建用户",
                isLoading: isProcessing,
                action: handleConfiguration
            )
            .disabled(isProcessing)
            
            DocumentationTipView {
                showingSafari = true
            }
        }
    }
    
    // MARK: - Step 2: Classroom Creation
    private var classroomCreationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("步骤 2: 创建课堂")
            
            Text("配置已完成，现在可以创建课堂。")
                .font(.body)
            
            SuccessIndicatorView(message: "用户已创建成功")
            
            HStack(spacing: 16) {
                PrimaryButton(
                    title: "创建课堂",
                    isLoading: isProcessing,
                    action: handleClassroomCreation
                )
                .disabled(isProcessing)
                
                SecondaryButton(
                    title: "重置",
                    action: { showingResetAlert = true }
                )
                .disabled(isProcessing)
            }
        }
    }
    
    // MARK: - Step 3: Enter Classroom
    private var enterClassroomStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("步骤 3: 进入课堂")
            
            Text("课堂已创建成功，请选择要进入的课堂：")
                .font(.body)
            
            if !classrooms.isEmpty {
                List(classrooms, id: \.roomId) { classroom in
                    Button(action: {
                        classroomInfo = classroomInfo?.copyWith(roomId: classroom.roomId)
                    }) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(classroom.roomName)
                                    .font(.headline)
                                Text("课堂ID: \(classroom.roomId)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if classroomInfo?.roomId == classroom.roomId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .frame(height: 300)
            }
            
            HStack(spacing: 16) {
                PrimaryButton(
                    title: "进入课堂",
                    action: handleEnterClassroom
                )
                
                SecondaryButton(
                    title: "刷新列表",
                    action: { fetchClassroomsFromAPI() }
                )
            }
        }
    }
    
    // MARK: - Helper Views
    private func stepTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
    }
    
    // MARK: - Business Logic
    private func handleConfiguration() {
        guard validateConfigurationInputs() else { return }
        
        isProcessing = true
        configureApiClient()
        
        Task {
            do {
                let response = try await TCICCloudAPI.shared.registerUser()
                
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.handleConfigurationSuccess(response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showError("注册失败，\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleClassroomCreation() {
        guard let info = classroomInfo else { return }
        
        isProcessing = true
        
        Task {
            do {
                let response = try await TCICCloudAPI.shared.createRoom(teacherId: info.userId)
                
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.handleClassroomCreationSuccess(response: response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showError("创建课堂失败，\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleEnterClassroom() {
        guard let info = classroomInfo else { return }
        onEnterClassroom(info)
    }
    
    // MARK: - Helper Methods
    private func validateConfigurationInputs() -> Bool {
        if secretKey.isEmpty || secretId.isEmpty || appId.isEmpty {
            showError("请填写完整的配置信息")
            return false
        }
        return true
    }
    
    private func configureApiClient() {
        TCICCloudAPI.shared.setConfig(
            secretId: secretId,
            secretKey: secretKey,
            appId: Int(appId) ?? 0
        )
        // 保存配置到 UserDefaults
        saveConfiguration()
    }
    
    private func saveConfiguration() {
        UserDefaults.standard.set(secretKey, forKey: "tcic_secretKey")
        UserDefaults.standard.set(secretId, forKey: "tcic_secretId")
        UserDefaults.standard.set(appId, forKey: "tcic_appId")
    }
    
    private func handleConfigurationSuccess(response: UserRegistrationResponse) {
        stepStatus.isConfigurationCompleted = true
        currentStepIndex = 1
        classroomInfo = ClassroomInfo(
            userId: response.userId,
            token: response.token
        )
        showSuccess("用户注册成功!")
    }
    
    private func fetchClassroomsFromAPI() {
         Task {
            do {
                let response = try await TCICCloudAPI.shared.getClassRooms()
                
                DispatchQueue.main.async {
                    self.classrooms = response
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.showError("获取课堂列表失败\(error.localizedDescription)")
                }
            }
        }
       
    }
    
    private func handleClassroomCreationSuccess(response: RoomCreationResponse) {
        stepStatus.isClassroomCreated = true
        currentStepIndex = 2
        let newClassroom = classroomInfo?.copyWith(roomId: response.roomId)
        classroomInfo = newClassroom
        
        // 改为调用API获取最新课堂列表
        fetchClassroomsFromAPI()
        
        showSuccess("课堂创建成功！")
    }
    
    private func resetWizard() {
        currentStepIndex = 0
        stepStatus.reset()
        isProcessing = false
        classroomInfo = nil
        
        // 不清除保存的配置，只重置界面
        
        showSuccess("已重置到第一步")
    }
    
    private func showError(_ message: String) {
        alertTitle = "错误"
        alertMessage = message
        showingAlert = true
    }
    
    private func showSuccess(_ message: String) {
        alertTitle = "成功"
        alertMessage = message
        showingAlert = true
    }
}
