import Foundation
import RoomPlan
import simd

// MARK: - RoomScannerManager
// 单例类，负责管理 RoomPlan 扫描生命周期，并将 CapturedRoom 数据
// 解构为 static_structures（不可动结构）和 dynamic_furnitures（可动家具）。

class RoomScannerManager: NSObject, ObservableObject {

    static let shared = RoomScannerManager()

    @Published var isScanning = false
    @Published var capturedRoom: CapturedRoom?

    private(set) var captureView: RoomCaptureView?

    private override init() {
        super.init()
    }

    // MARK: - Setup
    /// 将 Manager 与 RoomCaptureView 绑定，由 UIViewRepresentable 调用
    func setup(with view: RoomCaptureView) {
        self.captureView = view
        view.captureSession.delegate = self
    }

    // MARK: - Session Control
    func startSession() {
        guard let captureView else {
            print("[ZenSpace] captureView 未初始化")
            return
        }
        let configuration = RoomCaptureSession.Configuration()
        captureView.captureSession.run(configuration: configuration)
        DispatchQueue.main.async { self.isScanning = true }
    }

    func stopSession() {
        captureView?.captureSession.stop()
        DispatchQueue.main.async { self.isScanning = false }
    }

    // MARK: - Data Extraction
    private func extractAndPrint(_ room: CapturedRoom) {
        var staticStructures: [[String: Any]] = []
        var dynamicFurnitures: [[String: Any]] = []

        // --- 静态结构 (Static Structures) ---
        for surface in room.walls {
            staticStructures.append(surfaceDict(surface, label: "wall"))
        }
        if #available(iOS 17.0, *) {
            for surface in room.floors {
                staticStructures.append(surfaceDict(surface, label: "floor"))
            }
        }
        for surface in room.doors {
            let isOpen: Bool
            if case .door(let open) = surface.category { isOpen = open } else { isOpen = false }
            staticStructures.append(surfaceDict(surface, label: isOpen ? "door_open" : "door_closed"))
        }
        for surface in room.windows {
            staticStructures.append(surfaceDict(surface, label: "window"))
        }
        for surface in room.openings {
            staticStructures.append(surfaceDict(surface, label: "opening"))
        }

        // --- 动态家具 (Dynamic Furnitures) ---
        for object in room.objects {
            dynamicFurnitures.append(objectDict(object))
        }

        let output: [String: Any] = [
            "static_structures": staticStructures,
            "dynamic_furnitures": dynamicFurnitures
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: output, options: .prettyPrinted),
              let json = String(data: data, encoding: .utf8) else {
            print("[ZenSpace] JSON 序列化失败")
            return
        }

        print("\n========== ZenSpace Room Data ==========")
        print(json)
        print("========================================\n")
    }

    // MARK: - Dict Helpers
    private func surfaceDict(_ surface: CapturedRoom.Surface, label: String) -> [String: Any] {
        let t = surface.transform
        return [
            "category": label,
            "dimensions": [
                "width_m":  r2(surface.dimensions.x),
                "height_m": r2(surface.dimensions.y)
            ],
            "transform": [
                "position": ["x": r3(t.columns.3.x), "y": r3(t.columns.3.y), "z": r3(t.columns.3.z)],
                "forward":  ["x": r3(t.columns.2.x), "y": r3(t.columns.2.y), "z": r3(t.columns.2.z)]
            ]
        ]
    }

    private func objectDict(_ object: CapturedRoom.Object) -> [String: Any] {
        let t = object.transform
        return [
            "category": "\(object.category)",
            "dimensions": [
                "width_m":  r2(object.dimensions.x),
                "height_m": r2(object.dimensions.y),
                "depth_m":  r2(object.dimensions.z)
            ],
            "transform": [
                "position": ["x": r3(t.columns.3.x), "y": r3(t.columns.3.y), "z": r3(t.columns.3.z)],
                "forward":  ["x": r3(t.columns.2.x), "y": r3(t.columns.2.y), "z": r3(t.columns.2.z)]
            ]
        ]
    }

    // 四舍五入辅助
    private func r2(_ v: Float) -> Double { (Double(v) * 100).rounded() / 100 }
    private func r3(_ v: Float) -> Double { (Double(v) * 1000).rounded() / 1000 }
}

// MARK: - RoomCaptureSessionDelegate
extension RoomScannerManager: RoomCaptureSessionDelegate {

    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
        if let error {
            print("[ZenSpace] 扫描结束，发生错误: \(error.localizedDescription)")
            return
        }

        Task {
            do {
                let room = try await RoomBuilder(options: [.beautifyObjects]).capturedRoom(from: data)
                await MainActor.run {
                    self.capturedRoom = room
                    self.extractAndPrint(room)
                }
            } catch {
                print("[ZenSpace] RoomBuilder 构建失败: \(error.localizedDescription)")
            }
        }
    }

    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        // 实时更新：可在此处驱动进度 UI（里程碑二使用）
    }
}
