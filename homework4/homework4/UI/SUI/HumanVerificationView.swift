//
//  HumanVerificationView.swift
//  homework4
//
//  Created by Максим  on 03.06.2026.
//

import Foundation
import SwiftUI

struct HumanVerificationView: View {
    @ObservedObject var feedbackService: FeedbackService
    @State var isBeingDragged: Bool = false
    
    private let minumumDragDistance: CGFloat = 10
    
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Color.white
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(CornerRadius.standard)
            VStack {
                title
                testFIeld
                instructions
            }
            .padding()
        }
        .padding()
        .shadow(radius: 10)
    }
    
    var title: some View {
        Text("Verify that you are not a robot")
            .font(.headline)
            .padding()
    }
    
    var testFIeld: some View {
        RoundedRectangle(cornerRadius: CornerRadius.standard)
            .fill(isBeingDragged ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .animation(.easeOut(duration: 0.2), value: isBeingDragged)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .gesture(DragGesture(minimumDistance: minumumDragDistance)
                .onChanged { _ in
                    withAnimation(.easeInOut) {
                        isBeingDragged = true
                    }
                }
                .onEnded { value in
                    withAnimation(.easeInOut) {
                        isBeingDragged = false
                        hadleDragEnded(value)
                    }
                }
            )
    }
    
    var instructions: some View {
        HStack {
            Text("Next action: swipe")
            Text(feedbackService.currentInstruction)
        }
    }
    
    func hadleDragEnded(_ value: DragGesture.Value) {
        let userGesture = HumanVerificationView.identifyUserGesture(gestureValue: value)
        feedbackService.validateDragGesture(userGesture)
        guard feedbackService.isLastGestureValid else {
            onFinish()
            return
        }
        
        feedbackService.goToNextGesture()
        guard feedbackService.currentGesture != nil else {
            onFinish()
            return
        }
    }
}

extension HumanVerificationView {
    static func identifyUserGesture(gestureValue value: DragGesture.Value) -> VerificationGesture {
        let widthChange = abs(value.translation.width)
        let heightChange = abs(value.translation.height)
        var userGesture: VerificationGesture
        
        if widthChange > heightChange {
            userGesture = value.translation.width > 0 ? .leftToRight : .rightToLeft
        } else {
            userGesture = value.translation.height > 0 ? .topToBottom : .bottomToTop
        }
        
        return userGesture
    }
}
