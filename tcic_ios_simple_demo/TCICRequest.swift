//  TCICRequest.swift

import Foundation
import CryptoKit
import CommonCrypto

class TCICRequest {
    // 密钥参数
    static var secretId: String = ""
    static var secretKey: String = ""
    static var appId: Int = 0
    
    static func setConfig(secretId: String, secretKey: String, appId: Int) {
        TCICRequest.secretId = secretId
        TCICRequest.secretKey = secretKey
        TCICRequest.appId = appId
    }
    
    static func sendRequest(
        action: String,
        payload: [String: Any],
        region: String? = nil
    ) async throws -> [String: Any] {
        
        let service = "lcic"
        let host = "lcic.tencentcloudapi.com"
        let endpoint = "https://\(host)"
        let version = "2022-08-17"
        let algorithm = "TC3-HMAC-SHA256"
        
        // 获取当前时间戳
        let timestamp = Int(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
        
        // ************* 步骤 1：拼接规范请求串 *************
        let httpRequestMethod = "POST"
        let canonicalUri = "/"
        let canonicalQuerystring = ""
        let ct = "application/json; charset=utf-8"
        
        let payloadData = try JSONSerialization.data(withJSONObject: payload, options: [])
        let payloadString = String(data: payloadData, encoding: .utf8) ?? ""
        
        let canonicalHeaders = "content-type:\(ct)\nhost:\(host)\nx-tc-action:\(action.lowercased())\n"
        let signedHeaders = "content-type;host;x-tc-action"
        let hashedRequestPayload = sha256Hash(payloadString)
        
        let canonicalRequest = """
\(httpRequestMethod)
\(canonicalUri)
\(canonicalQuerystring)
\(canonicalHeaders)
\(signedHeaders)
\(hashedRequestPayload)
"""
        
        print("Canonical Request:")
        print(canonicalRequest)
        
        // ************* 步骤 2：拼接待签名字符串 *************
        let credentialScope = "\(date)/\(service)/tc3_request"
        let hashedCanonicalRequest = sha256Hash(canonicalRequest)
        
        let stringToSign = """
\(algorithm)
\(timestamp)
\(credentialScope)
\(hashedCanonicalRequest)
"""
        
        print("String to Sign:")
        print(stringToSign)
        
        // ************* 步骤 3：计算签名 *************
        let secretDate = hmacSha256(key: "TC3\(secretKey)", message: date)
        let secretService = hmacSha256(key: secretDate, message: service)
        let secretSigning = hmacSha256(key: secretService, message: "tc3_request")
        let signature = hmacSha256Hex(key: secretSigning, message: stringToSign)
        
        print("Signature:")
        print(signature)
        
        // ************* 步骤 4：拼接 Authorization *************
        let authorization = "\(algorithm) Credential=\(secretId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        
        print("Authorization:")
        print(authorization)
        
        // 发送HTTP请求
        return try await performRequest(
            endpoint: endpoint,
            payload: payloadData,
            headers: [
                "Authorization": authorization,
                "Content-Type": "application/json; charset=utf-8",
                "Host": host,
                "X-TC-Action": action,
                "X-TC-Timestamp": String(timestamp),
                "X-TC-Version": version,
                "X-TC-Region": region ?? ""
            ]
        )
    }
    
    // MARK: - 加密工具方法
    private static func sha256Hash(_ string: String) -> String {
        let data = Data(string.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private static func hmacSha256(key: String, message: String) -> Data {
        let keyData = Data(key.utf8)
        let messageData = Data(message.utf8)
        let key256 = SymmetricKey(data: keyData)
        let signature = HMAC<SHA256>.authenticationCode(for: messageData, using: key256)
        return Data(signature)
    }
    
    private static func hmacSha256(key: Data, message: String) -> Data {
        let messageData = Data(message.utf8)
        let key256 = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: messageData, using: key256)
        return Data(signature)
    }
    
    private static func hmacSha256Hex(key: Data, message: String) -> String {
        let messageData = Data(message.utf8)
        let key256 = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: messageData, using: key256)
        return Data(signature).map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - HTTP请求方法
    private static func performRequest(
        endpoint: String,
        payload: Data,
        headers: [String: String]
    ) async throws -> [String: Any] {
        
        guard let url = URL(string: endpoint) else {
            throw TCICRequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = payload
        
        // 设置请求头
        for (key, value) in headers {
            if !value.isEmpty {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TCICRequestError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw TCICRequestError.httpError(httpResponse.statusCode)
            }
            
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw TCICRequestError.invalidJSONResponse
            }
            
            return jsonResponse
            
        } catch {
            print("请求失败: \(error)")
            throw error
        }
    }
}

// MARK: - 错误定义
enum TCICRequestError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case invalidJSONResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .invalidJSONResponse:
            return "无效的JSON响应"
        }
    }
}
