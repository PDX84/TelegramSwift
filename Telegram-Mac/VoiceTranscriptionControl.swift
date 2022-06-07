//
//  VoiceTranscriptionControl.swift
//  Telegram
//
//  Created by Mike Renoir on 19.05.2022.
//  Copyright © 2022 Telegram. All rights reserved.
//

import Foundation
import TGUIKit
import QuartzCore

final class VoiceTranscriptionControl: Control {
    
    
    enum TranscriptionState : Equatable {
        case possible
        case inProgress
        case expanded(Bool)
        case collapsed(Bool)
    }

    
    private var inProgressLayer: CAShapeLayer?

    let animationView: LottiePlayerView
    required init(frame frameRect: NSRect) {
        animationView = LottiePlayerView(frame: frameRect.size.bounds)
        super.init(frame: frameRect)
        addSubview(animationView)
        
        
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var state: TranscriptionState?
    
    func update(state: TranscriptionState, parameters: ChatMediaVoiceLayoutParameters, transition: ContainedViewLayoutTransition) {
        
        self.backgroundColor = parameters.presentation.grayText.withAlphaComponent(0.1)
        let previousState = self.state
        self.state = state
        
        let size = self.frame.size
        let cornerRadius = self.layer?.cornerRadius ?? 8
        
        let inProgress: Bool
        switch state {
        case .inProgress:
            inProgress = true
        case let .expanded(progress), let .collapsed(progress):
            inProgress = progress
        default:
            inProgress = false
        }
        
        if inProgress {
            if self.inProgressLayer == nil {
                let inProgressLayer = CAShapeLayer()
                inProgressLayer.isOpaque = false
                inProgressLayer.backgroundColor = nil
                inProgressLayer.fillColor = nil
                inProgressLayer.lineCap = .round
                inProgressLayer.lineWidth = 1.5
                
                let path = CGMutablePath()
                path.addRoundedRect(in: CGRect(origin: CGPoint(), size: size), cornerWidth: cornerRadius, cornerHeight: cornerRadius)
                inProgressLayer.path = path
                
                self.inProgressLayer = inProgressLayer
                
                let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
                endAnimation.fromValue = CGFloat(0.0) as NSNumber
                endAnimation.toValue = CGFloat(1.0) as NSNumber
                endAnimation.duration = 1.25
                endAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                endAnimation.fillMode = .forwards
                endAnimation.repeatCount = .infinity
                inProgressLayer.add(endAnimation, forKey: "strokeEnd")
                
                let startAnimation = CABasicAnimation(keyPath: "strokeStart")
                startAnimation.fromValue = CGFloat(0.0) as NSNumber
                startAnimation.toValue = CGFloat(1.0) as NSNumber
                startAnimation.duration = 1.25
                startAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                startAnimation.fillMode = .forwards
                startAnimation.repeatCount = .infinity
                inProgressLayer.add(startAnimation, forKey: "strokeStart")
                
                self.layer?.addSublayer(inProgressLayer)
            }
        } else {
            if let inProgressLayer = self.inProgressLayer {
                self.inProgressLayer = nil
                if transition.isAnimated {
                    inProgressLayer.animateAlpha(from: 1.0, to: 0.0, duration: 0.15, removeOnCompletion: false, completion: { [weak inProgressLayer] _ in
                        inProgressLayer?.removeFromSuperlayer()
                    })
                } else {
                    inProgressLayer.removeFromSuperlayer()
                }
            }
        }
        
        
        let animation: LocalAnimatedSticker
        switch state {
        case .possible:
            animation = .voice_to_text
        case .inProgress:
            animation = .voice_to_text
        case .collapsed:
            animation = .text_to_voice
        case .expanded:
            animation = .voice_to_text
        }
        
        let colors:[LottieColor] = [.init(keyPath: "", color: parameters.presentation.activityBackground)]

        self.inProgressLayer?.strokeColor = parameters.presentation.activityBackground.cgColor

        if let data = animation.data, state != previousState {
            
            let play: LottiePlayPolicy
            if previousState == nil || state == .inProgress {
                play = .framesCount(1)
            } else {
                play = .onceEnd
            }
            
            let animation = LottieAnimation(compressed: data, key: .init(key: .bundle(animation.rawValue), size: size), playPolicy: play, colors: colors, runOnQueue: .mainQueue(), metalSupport: false)
            
            animationView.set(animation)
        }

    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }

}


//        "icon.Group 3.Stroke 1": foregroundColor,
//                                        "icon.Group 1.Stroke 1": foregroundColor,
//                                        "icon.Group 4.Stroke 1": foregroundColor,
//                                        "icon.Group 2.Stroke 1": foregroundColor,
//                                        "Artboard Copy 2 Outlines.Group 5.Stroke 1": foregroundColor,
//                                        "Artboard Copy 2 Outlines.Group 1.Stroke 1": foregroundColor,
//                                        "Artboard Copy 2 Outlines.Group 4.Stroke 1": foregroundColor,
//                                        "Artboard Copy Outlines.Group 1.Stroke 1": foregroundColor,