/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles keyboard (OS X), touch (iOS) and controller (iOS, tvOS) input for controlling the game.
*/

import simd
import SceneKit
import GameController




extension GameViewController {

    // MARK: Controller orientation
    
    private static let controllerAcceleration = Float(1.0 / 10.0)
    private static let controllerDirectionLimit = float2(1.0)

    
    // MARK: Touch Events
    
    #if os(iOS)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if gameView.virtualDPadBounds().contains(touch.location(in: gameView)) {
                // We're in the dpad
                if padTouch == nil {
                    padTouch = touch
                    controllerStoredDirection = float2(0.0)
                }
            } else if panningTouch == nil {
                // Start panning
                panningTouch = touches.first
            }
            
            if padTouch != nil && panningTouch != nil {
                break // We already have what we need
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = panningTouch {
            let displacement = (float2(touch.location(in: view)) - float2(touch.previousLocation(in: view)))
            panCamera(displacement)
        }
        
        if let touch = padTouch {
            let displacement = (float2(touch.location(in: view)) - float2(touch.previousLocation(in: view)))
            controllerStoredDirection = clamp(mix(controllerStoredDirection, displacement, t: GameViewController.controllerAcceleration), min: -GameViewController.controllerDirectionLimit, max: GameViewController.controllerDirectionLimit)
        }
    }
    
    func commonTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = panningTouch {
            if touches.contains(touch) {
                panningTouch = nil
            }
        }
        
        if let touch = padTouch {
            if touches.contains(touch) || event?.touches(for: view)?.contains(touch) == false {
                padTouch = nil
                controllerStoredDirection = float2(0.0)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    #endif
 
}
