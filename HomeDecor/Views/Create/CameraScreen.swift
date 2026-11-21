//
//  CameraScreen.swift
//  HomeDecor
//
//  Create flow — Camera (Figma 12:34826). A custom AVFoundation viewfinder with
//  a coral framing guide, a hint chip, and a shutter / flip / library bar.
//  Capturing (or picking from the library chip) hands the photo to Adjust Photo.
//
//  The Simulator has no camera, so the preview is black there — the chrome and
//  the library path still work; real capture needs a device.
//

import SwiftUI
import Factory
import AVFoundation
import PhotosUI

// MARK: - Capture session

final class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "home-decor.camera")
    private var isFront = false
    private var handler: ((UIImage?) -> Void)?

    func configure() {
        queue.async { [self] in
            session.beginConfiguration()
            session.sessionPreset = .photo
            session.inputs.forEach { session.removeInput($0) }
            let pos: AVCaptureDevice.Position = isFront ? .front : .back
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: pos),
               let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) {
                session.addInput(input)
            }
            if !session.outputs.contains(output), session.canAddOutput(output) { session.addOutput(output) }
            session.commitConfiguration()
        }
    }

    func start() { queue.async { if !self.session.isRunning { self.session.startRunning() } } }
    func stop()  { queue.async { if self.session.isRunning { self.session.stopRunning() } } }
    func flip()  { queue.async { self.isFront.toggle() }; configure() }

    func capture(_ completion: @escaping (UIImage?) -> Void) {
        handler = completion
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let image = photo.fileDataRepresentation().flatMap { UIImage(data: $0) }.map { PhotoTools.normalized($0) }
        DispatchQueue.main.async { self.handler?(image); self.handler = nil }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK: - Screen

struct CameraScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.createSession) private var session: CreateSession
    @StateObject private var cam = CameraController()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraPreview(session: cam.session).ignoresSafeArea()

            LinearGradient(stops: [
                .init(color: .black.opacity(0.55), location: 0),
                .init(color: .black.opacity(0),    location: 0.20),
                .init(color: .black.opacity(0),    location: 0.72),
                .init(color: Color(hex: 0x050812).opacity(0.9), location: 1),
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            FramingGuide()
                .padding(.horizontal, 30)
                .padding(.top, 60)
                .padding(.bottom, 180)

            VStack(spacing: 0) {
                header
                hint
                Spacer()
                cameraBar
            }
        }
        .onAppear { cam.configure(); cam.start() }
        .onDisappear { cam.stop() }
        .onChange(of: pickerItem) { load($0) }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            Text("take_a_photo".localized)
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            HStack {
                Button { app.navi.pop() } label: {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .frame(height: 44).padding(.horizontal, 20).padding(.top, 8)
    }

    private var hint: some View {
        HStack(spacing: 6) {
            Image(systemName: "house").font(.system(size: 11, weight: .semibold))
            Text("camera_hint".localized).font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14).frame(height: 32)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.5), lineWidth: 1))
        .padding(.top, 4)
    }

    private var cameraBar: some View {
        HStack {
            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 18, weight: .regular)).foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.6), lineWidth: 1.5))
            }
            Spacer()
            Button {
                cam.capture { img in
                    guard let img else { return }
                    session.captured = img
                    app.navi.push(.adjustPhoto)
                }
            } label: {
                Circle().fill(.white).frame(width: 62, height: 62)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 4).frame(width: 78, height: 78))
                    .frame(width: 78, height: 78)
            }
            .buttonStyle(PressableStyle())
            Spacer()
            Button { cam.flip() } label: {
                Image(systemName: "arrow.triangle.2.circlepath").font(.system(size: 18, weight: .medium)).foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 36)
        .padding(.bottom, 44)
    }

    private func load(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                let normalized = PhotoTools.normalized(image)
                await MainActor.run {
                    session.captured = normalized
                    pickerItem = nil
                    app.navi.push(.adjustPhoto)
                }
            }
        }
    }
}

/// Coral corner brackets + rule-of-thirds grid shown over the viewfinder.
struct FramingGuide: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let len: CGFloat = 26
            ZStack {
                // Thirds grid
                Path { p in
                    p.move(to: CGPoint(x: w/3, y: 0));   p.addLine(to: CGPoint(x: w/3, y: h))
                    p.move(to: CGPoint(x: 2*w/3, y: 0)); p.addLine(to: CGPoint(x: 2*w/3, y: h))
                    p.move(to: CGPoint(x: 0, y: h/3));   p.addLine(to: CGPoint(x: w, y: h/3))
                    p.move(to: CGPoint(x: 0, y: 2*h/3)); p.addLine(to: CGPoint(x: w, y: 2*h/3))
                }
                .stroke(.white.opacity(0.35), lineWidth: 1)

                // Coral corner brackets
                Path { p in
                    p.move(to: CGPoint(x: 0, y: len)); p.addLine(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: len, y: 0))
                    p.move(to: CGPoint(x: w - len, y: 0)); p.addLine(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w, y: len))
                    p.move(to: CGPoint(x: 0, y: h - len)); p.addLine(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: len, y: h))
                    p.move(to: CGPoint(x: w - len, y: h)); p.addLine(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w, y: h - len))
                }
                .stroke(AppColor.coral, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
        }
    }
}
