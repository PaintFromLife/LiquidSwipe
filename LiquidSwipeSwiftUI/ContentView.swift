//
//  ContentView.swift
//  LiquidSwipeSwiftUI
//
//  Created by Mark Goldin on 08/08/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var backColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var leftWaveZIndex: Double = 1
    @State var leftDraggingPoint: DragPointData = DragPointData(point: CGPoint(x: 0, y: 100), translation: CGSize(width: pad, height: 0))
    @State var leftDraggingPointAdjusted: CGPoint = CGPoint(x: circleRadius + 4, y: 100)
    @State var leftDraggingOpacity: Double = 1
    @State var leftIsDragging: Bool = false
    @State var leftColor: Color = LiquidSwipeSettings.shared.nextColor
    
    @State var rightWaveZIndex: Double = 4
    @State var rightDraggingPoint: DragPointData = DragPointData(point: CGPoint(x: 0, y: 300), translation: CGSize(width: pad, height: 0))
    @State var rightDraggingPointAdjusted: CGPoint = CGPoint(x: sizeW - circleRadius - 4, y: 300)
    @State var rightDraggingOpacity: Double = 1
    @State var rightIsDragging: Bool = false
    @State var rightColor: Color = LiquidSwipeSettings.shared.nextColor
    
    var body: some View {
        ZStack {
            backPath().foregroundColor(backColor)
            
            leftWave().zIndex(leftWaveZIndex)
            leftCircle().zIndex(leftWaveZIndex + 1)
            leftArrow().zIndex(leftWaveZIndex + 2)
            
            rightWave().zIndex(rightWaveZIndex)
            rightCircle().zIndex(rightWaveZIndex + 1)
            rightArrow().zIndex(rightWaveZIndex + 2)
        }
    }
    
    func backPath() -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: -100))
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.size.width, y: -100))
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.size.width, y: UIScreen.main.bounds.size.height))
        path.addLine(to: CGPoint(x: 0, y: UIScreen.main.bounds.size.height))
        
        return path
    }

    func leftWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: leftDraggingPoint,
                            isDragging: leftIsDragging,
                            alignment: .left ).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(leftColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 4
                    self.rightWaveZIndex = 1
                    
                    self.leftIsDragging = true
                    self.leftDraggingPoint = DragPointData(point: result.location, translation: result.translation)
                    
                    let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .left)
                    
                    self.leftDraggingPointAdjusted = data.0
                    self.leftDraggingOpacity = data.1
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.leftIsDragging = false
                    self.leftDraggingPoint = DragPointData(point: result.location, translation: result.translation)
                    
                    self.leftDraggingOpacity = 0
                }
                self.reload(actionWaveAlignment: .left, dx: self.leftDraggingPoint.translation.width)
            })
    }
    
    func rightWave() -> some View {
        func path(in rect: CGRect) -> Path {
            return WaveView(draggingPoint: rightDraggingPoint,
                            isDragging: rightIsDragging,
                            alignment: .right).path(in: rect)
        }
        
        return GeometryReader { geometry -> AnyView in
            let rect = geometry.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
        .foregroundColor(rightColor)
            .gesture(DragGesture()
                .onChanged { result in
                    self.leftWaveZIndex = 1
                    self.rightWaveZIndex = 4
                    
                    self.rightIsDragging = true
                    self.rightDraggingPoint = DragPointData(point: result.location, translation: result.translation)
                    
                    let data = WaveView.adjustedDragPoint(point: CGPoint(x: result.translation.width, y: result.location.y), alignment: .right)
                    
                    self.rightDraggingPointAdjusted = data.0
                    self.rightDraggingOpacity = data.1
            }
            .onEnded { result in
                withAnimation(.spring()) {
                    self.rightIsDragging = false
                    self.rightDraggingPoint = DragPointData(point: result.location, translation: result.translation)
                    
                    self.rightDraggingOpacity = 0
                }
                self.reload(actionWaveAlignment: .right, dx: -self.rightDraggingPoint.translation.width)
            })
    }
    
    func rightCircle() -> some View {
        let w = Length(circleRadius * 2.0)
        let color = Color(hex: 0x000000, alpha: 0.2)
        
        return Circle()
            .stroke(color)
            .frame(width: w, height: w)
            .position(rightDraggingPointAdjusted)
            .opacity(rightDraggingOpacity)
    }
    
    func leftCircle() -> some View {
        let w = Length(circleRadius * 2.0)
        let color = Color(hex: 0x000000, alpha: 0.2)
        
        return Circle()
            .stroke(color)
            .frame(width: w, height: w)
            .position(leftDraggingPointAdjusted)
            .opacity(leftDraggingOpacity)
    }
    
    func leftArrow() -> some View {
        return Rectangle()
            .trim(from: 1/2, to: 1)
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 10, height: 10)
            .rotationEffect(Angle(degrees: -135))
            .position(leftDraggingPointAdjusted)
            .opacity(leftDraggingOpacity)
    }
    
    func rightArrow() -> some View {
        return Rectangle()
            .trim(from: 1/2, to: 1)
            .stroke(Color.white, lineWidth: 2)
            .frame(width: 10, height: 10)
            .rotationEffect(Angle(degrees: 45))
            .position(rightDraggingPointAdjusted)
            .opacity(rightDraggingOpacity)
    }
    
    private func reload(actionWaveAlignment: WaveAlignment, dx: CGFloat) {
        let progress = WaveView.getProgress(dx: dx)
        
        if progress > 0.15 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let waveColor = actionWaveAlignment == .left ? self.leftColor : self.rightColor
                
                self.backColor = waveColor
                
                self.leftColor = LiquidSwipeSettings.shared.nextColor
                self.rightColor = LiquidSwipeSettings.shared.nextColor
                
                self.leftDraggingPoint = DragPointData(point: CGPoint(x: 0, y: 100), translation: CGSize(width: pad, height: 0))
                self.rightDraggingPoint = DragPointData(point: CGPoint(x: 0, y: 300), translation: CGSize(width: pad, height: 0))
                self.leftDraggingPointAdjusted = CGPoint(x: circleRadius + 4, y: 100)
                self.rightDraggingPointAdjusted = CGPoint(x: sizeW - circleRadius - 4, y: 300)
                
                withAnimation(.spring()) {
                    self.leftDraggingOpacity = 1.0
                    self.rightDraggingOpacity = 1.0
                }
            }
        } else {
            withAnimation(.spring()) {
                self.leftDraggingOpacity = 1.0
                self.leftDraggingPointAdjusted = CGPoint(x: circleRadius + 4, y: leftDraggingPoint.point.y)
                
                self.rightDraggingOpacity = 1.0
                self.rightDraggingPointAdjusted = CGPoint(x: sizeW - circleRadius - 4, y: rightDraggingPoint.point.y)
            }
        }
    }
}





