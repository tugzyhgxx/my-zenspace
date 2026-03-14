import SwiftUI
import RoomPlan

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var scanner = RoomScannerManager.shared

    var body: some View {
        ZStack {
            // 全屏相机扫描视图
            RoomCaptureViewRepresentable()
                .ignoresSafeArea()

            // 底部控制栏
            VStack {
                Spacer()

                // 状态提示
                if scanner.isScanning {
                    Text("正在扫描房间…")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 16)
                }

                // 按钮行
                HStack(spacing: 24) {
                    ScanButton(title: "开始扫描", color: .blue, disabled: scanner.isScanning) {
                        scanner.startSession()
                    }

                    ScanButton(title: "结束分析", color: .green, disabled: !scanner.isScanning) {
                        scanner.stopSession()
                    }
                }
                .padding(.bottom, 52)
            }
        }
    }
}

// MARK: - RoomCaptureView Wrapper
struct RoomCaptureViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> RoomCaptureView {
        let view = RoomCaptureView(frame: .zero)
        RoomScannerManager.shared.setup(with: view)
        return view
    }

    func updateUIView(_ uiView: RoomCaptureView, context: Context) {}
}

// MARK: - ScanButton
struct ScanButton: View {
    let title: String
    let color: Color
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(disabled ? Color.gray : color)
                )
        }
        .disabled(disabled)
    }
}

#Preview {
    ContentView()
}
