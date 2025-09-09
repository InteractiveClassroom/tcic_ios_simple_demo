//  TCICCloudAPI.swift

import Foundation

class TCICCloudAPI {
    static let shared = TCICCloudAPI()
    
    private init() {}
    
    func setConfig(secretId: String, secretKey: String, appId: Int) {
        TCICRequest.setConfig(secretId: secretId, secretKey: secretKey, appId: appId)
    }
    
    func registerUser() async throws -> UserRegistrationResponse {
        let payload: [String: Any] = [
            "SdkAppId": TCICRequest.appId
        ]
        
        let response = try await TCICRequest.sendRequest(
            action: "RegisterUser",
            payload: payload
        )
        
        // 检查是否有错误
        if let responseInfo = response["Response"] as? [String: Any],
           let error = responseInfo["Error"] as? [String: Any] {
            let errorMessage = error["Message"] as? String ?? "未知错误"
            throw TCICAPIError.apiError(errorMessage)
        }
        
        // 解析成功响应
        guard let responseInfo = response["Response"] as? [String: Any],
              let userId = responseInfo["UserId"] as? String,
              let token = responseInfo["Token"] as? String else {
            throw TCICAPIError.invalidResponse
        }
        
        return UserRegistrationResponse(userId: userId, token: token)
    }
    
    func createRoom(teacherId: String) async throws -> RoomCreationResponse {
        let currentTimestamp = Int(Date().timeIntervalSince1970)

        let payload: [String: Any] = [
                    "Name": "互动课堂Demo测试房间",
                    "StartTime": currentTimestamp + 10,
                    "EndTime": currentTimestamp + 30 * 60,
                    "SdkAppId": TCICRequest.appId,
                    "Resolution": 1,
                    "MaxMicNumber": 6,
                    "SubType": "videoDoc",
                    "TeacherId": teacherId
                ]
        
        let response = try await TCICRequest.sendRequest(
            action: "CreateRoom",
            payload: payload
        )
        
        // 检查是否有错误
        if let responseInfo = response["Response"] as? [String: Any],
           let error = responseInfo["Error"] as? [String: Any] {
            let errorMessage = error["Message"] as? String ?? "未知错误"
            throw TCICAPIError.apiError(errorMessage)
        }
        
        // 解析成功响应
        guard let responseInfo = response["Response"] as? [String: Any],
              let roomId = responseInfo["RoomId"] as? Int else {
            throw TCICAPIError.invalidResponse
        }
        
        return RoomCreationResponse(roomId: String(roomId))
    }
}

// MARK: - API错误定义
enum TCICAPIError: Error, LocalizedError {
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "API响应格式错误"
        }
    }
}
