//  WizardUIComponents.swift

import SwiftUI
import SafariServices

// MARK: - Step Indicator
struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    let stepStatus: WizardStepStatus
    
    private let stepTitles = ["配置参数", "创建课堂", "进入课堂"]
    
    var body: some View {
        HStack {
            ForEach(0..<totalSteps, id: \.self) { index in
                HStack {
                    StepCircle(
                        index: index,
                        title: stepTitles[index],
                        isCompleted: isStepCompleted(index),
                        isCurrent: currentStep == index
                    )
                    
                    if index < totalSteps - 1 {
                        StepConnector(isCompleted: currentStep > index)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private func isStepCompleted(_ index: Int) -> Bool {
        switch index {
        case 0: return stepStatus.isConfigurationCompleted
        case 1: return stepStatus.isClassroomCreated
        case 2: return stepStatus.isSetupCompleted
        default: return false
        }
    }
}

struct StepCircle: View {
    let index: Int
    let title: String
    let isCompleted: Bool
    let isCurrent: Bool
    
    private var isPassed: Bool {
        isCompleted
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(circleColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isPassed ? "checkmark" : "circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                )
            
            Text(title)
                .font(.caption)
                .fontWeight(isPassed || isCurrent ? .bold : .regular)
                .foregroundColor(isPassed || isCurrent ? .primary : .secondary)
        }
    }
    
    private var circleColor: Color {
        if isPassed {
            return .green
        } else if isCurrent {
            return .blue
        } else {
            return Color(.systemGray4)
        }
    }
}

struct StepConnector: View {
    let isCompleted: Bool
    
    var body: some View {
        Rectangle()
            .fill(isCompleted ? .green : Color(.systemGray4))
            .frame(height: 2)
            .frame(maxWidth: 60)
    }
}

// MARK: - Form Components
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .foregroundColor(.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
}

// MARK: - Info Views
struct SuccessIndicatorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            Text(message)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

struct ClassroomInfoView: View {
    let classroomInfo: ClassroomInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(text: "配置信息已保存")
            InfoRow(text: "用户创建成功 \(classroomInfo.userId)")
            InfoRow(text: "课堂创建成功 \(classroomInfo.roomId)")
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

struct InfoRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct DocumentationTipView: View {
    let onTapLink: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("请注意腾讯云API的密钥等信息需根据业务放到您的服务端，避免泄漏。")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button("点击查看文档") {
                    onTapLink()
                }
                .font(.body)
                .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
