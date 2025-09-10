//
//  WizardModels.swift
//  tcic_ios_simple_demo
//
//  Created by joyxian on 2025/9/9.
//

import Foundation


// 向导步骤状态
class WizardStepStatus: ObservableObject {
    @Published var isConfigurationCompleted = false
    @Published var isClassroomCreated = false
    @Published var isSetupCompleted = false
    
    func reset() {
        isConfigurationCompleted = false
        isClassroomCreated = false
        isSetupCompleted = false
    }
}

// 课堂信息
struct ClassroomInfo {
    let userId: String
    let token: String
    var roomId: String
    
    init(userId: String, token: String, roomId: String = "0") {
        self.userId = userId
        self.token = token
        self.roomId = roomId
    }
    
    func copyWith(userId: String? = nil, token: String? = nil, roomId: String? = nil) -> ClassroomInfo {
        return ClassroomInfo(
            userId: userId ?? self.userId,
            token: token ?? self.token,
            roomId: roomId ?? self.roomId
        )
    }
}

// API响应模型
struct UserRegistrationResponse {
    let userId: String
    let token: String
}

struct RoomCreationResponse {
    let roomId: String
    let roomName: String
}

// 角色枚举
enum UserRole: String, CaseIterable {
    case student = "student"
    case teacher = "teacher"
    case assistant = "assistant"
    case observer = "observer"
    
    var roleCode: Int {
        switch self {
        case .student: return 0
        case .teacher: return 1
        case .assistant: return 3
        case .observer: return 4
        }
    }
}
