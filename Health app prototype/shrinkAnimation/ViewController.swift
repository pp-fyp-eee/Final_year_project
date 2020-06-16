//
//  ViewController.swift
//  shrinkAnimation
//
//  Created by Pranav Paul on 10/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override func viewWillLayoutSubviews() {
        setupCards()
        addLabelledImageViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addExpandedViewElements()
        fadeInMainShadow()
        setupPressDetection()
    
    }
    
    let cardSectionSelector: UIControl = UIControl(frame: CGRect(x: 112, y: 100, width: 140, height: 139))
    
    var currentHealthSelection: YourHealthSelection = .skinTemperature {
        willSet {
            if newValue != currentHealthSelection && didExpand {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
        didSet {
            if currentHealthSelection == .heartRate {
                heartLabel.opacity = 1.0
                heartImageView.alpha = 1.0
                animateMovementOfCardSelector(to: YourHealthSelectorPositions().heartFrame)
                
                currentSelectionTextLayer.string = "Heart rate:"
                // TODO: BLE readings
                currentReadingTextLayer.string = "95 bpm"
                currentReadingResultTextLayer.string = "High heart rate"
            }
            else if currentHealthSelection == .skinTemperature {
                temperatureLabel.opacity = 1.0
                temperatureImageView.alpha = 1.0
                animateMovementOfCardSelector(to: YourHealthSelectorPositions().temperatureFrame)
                
                currentSelectionTextLayer.string = "Skin temperature:"
                currentReadingTextLayer.string = "39.0 ℃"
                currentReadingResultTextLayer.string = "High temperature"
            }
            else if currentHealthSelection == .bloodPressure {
                pressureLabel.opacity = 1.0
                pressureImageView.alpha = 1.0
                animateMovementOfCardSelector(to: YourHealthSelectorPositions().bloodPressureFrame)
                
                currentSelectionTextLayer.string = "Blood pressure:"
                currentReadingTextLayer.string = "124/83 mmHg"
                currentReadingResultTextLayer.string = "High pressure"
            }
         
        }
    }
    
    let yourHealthCard: UIControl = UIControl(frame: CGRect(x: 17, y: 161, width: 380, height: 230))
   
    let heartImageView = UIImageView(frame: CGRect(x: 21, y: 78, width: 70, height: 67))
    let heartLabel = CATextLayer()
    let heartRateButton: UIButton = UIButton(frame: YourHealthSelectorPositions().heartFrame)
    
    let temperatureImageView = UIImageView(frame: CGRect(x: 150, y: 78, width: 68, height: 67))
    let temperatureLabel = CATextLayer()
    let temperatureButton: UIButton = UIButton(frame: YourHealthSelectorPositions().temperatureFrame)
    
    let pressureImageView = UIImageView(frame: CGRect(x: 290, y: 77, width: 68, height: 67))
    let pressureLabel = CATextLayer()
    let pressureButton: UIButton = UIButton(frame: YourHealthSelectorPositions().bloodPressureFrame)
    
    let currentSelectionTextLayer = CATextLayer()
    let currentReadingTextLayer = CATextLayer()
    let currentReadingResultImageView = UIImageView(frame: CGRect(x: 25, y: 388.56, width: 60, height: 60))
    let currentReadingResultTextLayer = CATextLayer()
    let lastMeasuredTextLayer = CATextLayer()
    
    var helpSubViews: [UIView] = []
    let helpImageView = UIImageView(frame: CGRect(x: 21, y: 77, width: 374, height: 107))
    let helpCloseButton = UIButton(frame: CGRect(x: 167, y: 559, width: 78, height: 78))
    
    var textLayer = CATextLayer()
        

    private func setupCards() {
        
        textLayer.string = "Your health"
        if !didExpand {textLayer.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.bold)}
        else {textLayer.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.heavy)}
        textLayer.fontSize = 35
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.frame = CGRect(x: 16, y: 13, width: 347, height: 49)
        yourHealthCard.layer.addSublayer(textLayer)
        
        yourHealthCard.layer.cornerRadius = 17
        yourHealthCard.layer.masksToBounds = true
        yourHealthCard.setGradientBackgroundColour(colourOne: Colours.lightPurple, colourTwo: Colours.darkPurple)
        
        view.addSubview(yourHealthCard)
        
        yourHealthCard.addTarget(self, action: #selector(touchDown), for: [.touchDown])
        yourHealthCard.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragInside])
    
    }
    
    private func addLabelledImageViews() {
        heartImageView.image = UIImage(named: "heart.png")
        yourHealthCard.addSubview(heartImageView)
        
        heartLabel.string = "Heart rate"
        heartLabel.font = UIFont.systemFont(ofSize: 24.5, weight: .bold)
        heartLabel.fontSize = 24.5
        heartLabel.isWrapped = true
        heartLabel.alignmentMode = .center
        heartLabel.foregroundColor = UIColor.white.cgColor
        heartLabel.contentsScale = UIScreen.main.scale
        heartLabel.frame = CGRect(x: 21, y: 151, width: 71, height: 69)
        yourHealthCard.layer.addSublayer(heartLabel)
        
        temperatureImageView.image = UIImage(named: "thermometer.png")
        yourHealthCard.addSubview(temperatureImageView)
        
        temperatureLabel.string = "Skin temperature"
        temperatureLabel.font = UIFont.systemFont(ofSize: 24.5, weight: .bold)
        temperatureLabel.fontSize = 24.5
        temperatureLabel.isWrapped = true
        temperatureLabel.alignmentMode = .center
        temperatureLabel.foregroundColor = UIColor.white.cgColor
        temperatureLabel.contentsScale = UIScreen.main.scale
        temperatureLabel.frame = CGRect(x: 100, y: 151, width: 162, height: 74)
        yourHealthCard.layer.addSublayer(temperatureLabel)
        
        pressureImageView.image = UIImage(named: "bloodPressure.png")
        yourHealthCard.addSubview(pressureImageView)
        
        pressureLabel.string = "Blood pressure"
        pressureLabel.font = UIFont.systemFont(ofSize: 24.5, weight: .bold)
        pressureLabel.fontSize = 24.5
        pressureLabel.isWrapped = true
        pressureLabel.alignmentMode = .center
        pressureLabel.foregroundColor = UIColor.white.cgColor
        pressureLabel.contentsScale = UIScreen.main.scale
        pressureLabel.frame = CGRect(x: 265, y: 151, width: 109, height: 69)
        yourHealthCard.layer.addSublayer(pressureLabel)
        
    }
    
    private func addExpandedViewElements() {
        
        cardSectionSelector.backgroundColor = UIColor(red: 93/255, green: 60/255, blue: 187/255, alpha: 1.0)
        cardSectionSelector.alpha = 0.0
        cardSectionSelector.layer.cornerRadius = 17
        cardSectionSelector.layer.shadowColor = UIColor.black.cgColor
        cardSectionSelector.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardSectionSelector.layer.shadowOpacity = 0.7
        cardSectionSelector.layer.shadowRadius = 4.0
        yourHealthCard.addSubview(cardSectionSelector)

        currentSelectionTextLayer.string = "Skin temperature:"
        currentSelectionTextLayer.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        currentSelectionTextLayer.fontSize = 38
        currentSelectionTextLayer.isWrapped = true
        currentSelectionTextLayer.alignmentMode = .left
        currentSelectionTextLayer.foregroundColor = UIColor.white.cgColor
        currentSelectionTextLayer.contentsScale = UIScreen.main.scale
        currentSelectionTextLayer.frame = CGRect(x: 25, y: 255, width: 331, height: 56)
        currentSelectionTextLayer.opacity = 0
        yourHealthCard.layer.addSublayer(currentSelectionTextLayer)
        
        currentReadingTextLayer.string = "39.0 ℃"
        currentReadingTextLayer.font = UIFont.systemFont(ofSize: 45, weight: .black)
        currentReadingTextLayer.fontSize = 45
        currentReadingTextLayer.isWrapped = true
        currentReadingTextLayer.alignmentMode = .left
        currentReadingTextLayer.foregroundColor = UIColor.white.cgColor
        currentReadingTextLayer.contentsScale = UIScreen.main.scale
        currentReadingTextLayer.frame = CGRect(x: 25, y: 321, width: 396, height: 56)
        currentReadingTextLayer.opacity = 0
        yourHealthCard.layer.addSublayer(currentReadingTextLayer)
        
        currentReadingResultImageView.image = UIImage(named: "high_reading")
        currentReadingResultImageView.alpha = 0
        yourHealthCard.addSubview(currentReadingResultImageView)
        
        currentReadingResultTextLayer.string = "High temperature"
        currentReadingResultTextLayer.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        currentReadingResultTextLayer.fontSize = 28
        currentReadingResultTextLayer.isWrapped = true
        currentReadingResultTextLayer.alignmentMode = .left
        currentReadingResultTextLayer.foregroundColor = UIColor.white.cgColor
        currentReadingResultTextLayer.contentsScale = UIScreen.main.scale
        currentReadingResultTextLayer.frame = CGRect(x: 97, y: 400, width: 252, height: 34)
        currentReadingResultTextLayer.opacity = 0
        yourHealthCard.layer.addSublayer(currentReadingResultTextLayer)
        
        lastMeasuredTextLayer.string = "measured 2 mins ago"
        lastMeasuredTextLayer.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lastMeasuredTextLayer.fontSize = 20
        lastMeasuredTextLayer.isWrapped = true
        lastMeasuredTextLayer.alignmentMode = .right
        lastMeasuredTextLayer.foregroundColor = UIColor.white.cgColor
        lastMeasuredTextLayer.contentsScale = UIScreen.main.scale
        lastMeasuredTextLayer.frame = CGRect(x: 156, y: 453, width: 207, height: 30)
        lastMeasuredTextLayer.opacity = 0
        yourHealthCard.layer.addSublayer(lastMeasuredTextLayer)
    }
    

    // animators for main screen
    private var compressAnimator = UIViewPropertyAnimator()
    private var expandAnimator = UIViewPropertyAnimator()
    var didExpand = false
    var isShowingHelp = false
    
    
    // animators for help screen
    private var helpTranslationAnimator = UIViewPropertyAnimator()
    
    @objc private func touchDown() {
        
        if !didExpand && !isShowingHelp {
            self.heartLabel.removeAllAnimations()
            self.temperatureLabel.removeAllAnimations()
            self.pressureLabel.removeAllAnimations()
            
            compressAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: {
                self.yourHealthCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.view.viewWithTag(100)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            })
            compressAnimator.startAnimation()
        }
    }
    
    private func removeShadowView() {
        if let shadowView = self.view.viewWithTag(100) {
            shadowView.removeFromSuperview()
        }
    }
    
    private func animateMovementOfCardSelector(to position: CGRect) {
        
        // find out which elements to reduce alpha of
        var unselectedElements: [YourHealthSelection] = []
        
        for element in YourHealthSelection.allCases {
            if element != currentHealthSelection {
                unselectedElements.append(element)
            }
        }
        
        let movementAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.75, animations: {
            self.cardSectionSelector.frame = position
            
            for element in unselectedElements {
                if element == .heartRate {
                    self.heartLabel.opacity = 0.9
                    self.heartImageView.alpha = 0.9
                }
                else if element == .skinTemperature {
                    self.temperatureLabel.opacity = 0.9
                    self.temperatureImageView.alpha = 0.9
                }
                else if element == .bloodPressure {
                    self.pressureLabel.opacity = 0.9
                    self.pressureImageView.alpha = 0.9
                }
            }
            
        })
        
        movementAnimator.startAnimation()
    }
    
    private func createYourHealthSelectorButtons() {
        heartRateButton.isEnabled = true
        heartRateButton.setTitle("", for: .normal)
        heartRateButton.addTarget(self, action: #selector(tappedHeartRate), for: [.touchUpInside, .touchDragEnter, .touchDragInside])
        yourHealthCard.addSubview(heartRateButton)
        
        temperatureButton.isEnabled = true
        temperatureButton.setTitle("", for: .normal)
        temperatureButton.addTarget(self, action: #selector(tappedTemperature), for: [.touchUpInside, .touchDragEnter, .touchDragInside])
        yourHealthCard.addSubview(temperatureButton)
        
        pressureButton.isEnabled = true
        pressureButton.setTitle("", for: .normal)
        pressureButton.addTarget(self, action: #selector(tappedPressure), for: [.touchUpInside, .touchDragEnter, .touchDragInside])
        yourHealthCard.addSubview(pressureButton)
    }

    @objc func tappedHeartRate() {
        currentHealthSelection = .heartRate
    }
    
    @objc func tappedTemperature() {
        currentHealthSelection = .skinTemperature
    }
    
    @objc func tappedPressure() {
        currentHealthSelection = .bloodPressure
    }
    
    // expand cardView
    @objc private func touchUp(_ button: UIButton = UIButton(), forEvent event: UIEvent = UIEvent()) {
        
        if isShowingHelp {
            
            for subview in helpSubViews {
                subview.removeFromSuperview()
            }
            
            helpTranslationAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.53, animations: {
                self.yourHealthCard.transform = CGAffineTransform.identity
                self.view.viewWithTag(100)?.transform = CGAffineTransform.identity
            })
            
            helpTranslationAnimator.startAnimation()
            isShowingHelp = false
        }
        
        if !didExpand && !isShowingHelp {
            if let touchLocation = event.allTouches?.first {
                let point = touchLocation.location(in: button)
                
                if point.x > temperatureLabel.frame.maxX + 35 {
                    currentHealthSelection = .bloodPressure
                }
                else if point.x < temperatureLabel.frame.minX - 25 {
                    currentHealthSelection = .heartRate
                }
                else {
                    currentHealthSelection = .skinTemperature
                }
            }
            
            compressAnimator.stopAnimation(true)
            self.yourHealthCard.transform = CGAffineTransform.identity
            self.textLayer.removeAllAnimations()
            
            self.heartLabel.removeAllAnimations()
            self.temperatureLabel.removeAllAnimations()
            self.pressureLabel.removeAllAnimations()
        
            removeShadowView()
            createYourHealthSelectorButtons()

            expandAnimator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.9, animations: {
                print("expanding")
                self.yourHealthCard.frame = CGRect(x: 17, y: 54, width: 380, height: 489)
                
                // animate in selector
                self.cardSectionSelector.alpha = 1
                
                // animate in labels and icons below selector
                self.currentSelectionTextLayer.opacity = 1
                self.currentReadingTextLayer.opacity = 1
                self.currentReadingResultImageView.alpha = 1
                self.currentReadingResultTextLayer.opacity = 1
                self.lastMeasuredTextLayer.opacity = 0.8
            
                // animating icon sizes
                self.heartImageView.frame = CGRect(x: 41, y: 114, width: 55, height: 55)
                self.temperatureImageView.frame = CGRect(x: 155, y: 114, width: 55, height: 55)
                self.pressureImageView.frame = CGRect(x: 282, y: 114, width: 55, height: 55)
                
                
                // relative positioning wrt itself - ie move 14 points to right from its own previous value
                self.addRepositionAnimation(from: self.heartLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: 14, y: 29), element: self.heartLabel)
                self.addRepositionAnimation(from: self.temperatureLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: 0, y: 29), element: self.temperatureLabel)
                self.addRepositionAnimation(from: self.pressureLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: -10, y: 29), element: self.pressureLabel)
                
                self.scaleFontAnimation(from: 24.5, to: 20, element: self.heartLabel)
                self.scaleFontAnimation(from: 24.5, to: 20, element: self.temperatureLabel)
                self.scaleFontAnimation(from: 24.5, to: 20, element: self.pressureLabel)
            
                
                // animating title label
                let rectPositionAnimation = CABasicAnimation(keyPath: "transform.translation")
                rectPositionAnimation.fromValue = self.textLayer.value(forKey: "transform.translation")
                rectPositionAnimation.toValue = CGPoint(x: 10, y: 20)
                rectPositionAnimation.duration = 0.35
                rectPositionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                rectPositionAnimation.isRemovedOnCompletion = false
                rectPositionAnimation.fillMode = CAMediaTimingFillMode.forwards
                self.textLayer.add(rectPositionAnimation, forKey: nil)
                
                let fontSizeAnimation = CABasicAnimation(keyPath: "fontSize")
                fontSizeAnimation.fromValue = 35
                fontSizeAnimation.toValue = 45
                fontSizeAnimation.duration = 0.35
                fontSizeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                fontSizeAnimation.isRemovedOnCompletion = false
                fontSizeAnimation.fillMode = CAMediaTimingFillMode.forwards
                self.textLayer.add(fontSizeAnimation, forKey: nil)
                
                self.textLayer.font = UIFont.systemFont(ofSize: 45, weight: UIFont.Weight.heavy)
            })
            
            expandAnimator.startAnimation()
            
            didExpand = true
        }
    }
    
    private func addRepositionAnimation(from: Any, to: CGPoint, element: CALayer) {
        let repositionAnimation = CABasicAnimation(keyPath: "transform.translation")
        repositionAnimation.fromValue = from
        repositionAnimation.toValue = to
        repositionAnimation.duration = 0.4
        repositionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        repositionAnimation.isRemovedOnCompletion = false
        repositionAnimation.fillMode = CAMediaTimingFillMode.forwards
        element.add(repositionAnimation, forKey: nil)
    }
    
    private func scaleFontAnimation(from: Float, to: Float, element: CALayer) {
        let fontSizeAnimation = CABasicAnimation(keyPath: "fontSize")
        fontSizeAnimation.fromValue = from
        fontSizeAnimation.toValue = to
        fontSizeAnimation.duration = 0.4
        fontSizeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        fontSizeAnimation.isRemovedOnCompletion = false
        fontSizeAnimation.fillMode = CAMediaTimingFillMode.forwards
        element.add(fontSizeAnimation, forKey: nil)
    }
    
    @IBAction func reset(_ sender: Any) {
        
        // MARK: don't forget to remove prior scale animations before adding new ones
        self.textLayer.removeAllAnimations()
        self.heartLabel.removeAllAnimations()
        self.temperatureLabel.removeAllAnimations()
        self.pressureLabel.removeAllAnimations()
        
        helpTranslationAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.75, animations: {
            self.yourHealthCard.frame = CGRect(x: 17, y: 161, width: 380, height: 230)
            
            // title label
            let rectPositionAnimation = CABasicAnimation(keyPath: "transform.translation")
            rectPositionAnimation.fromValue = CGPoint(x: 10, y: 20)
            rectPositionAnimation.toValue = CGPoint(x: 4, y: 5)
            rectPositionAnimation.duration = 0.6
            rectPositionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            rectPositionAnimation.isRemovedOnCompletion = false
            rectPositionAnimation.fillMode = CAMediaTimingFillMode.forwards
            self.textLayer.add(rectPositionAnimation, forKey: "transform.translation")
                        
            let fontSizeAnimation2 = CABasicAnimation(keyPath: "fontSize")
            fontSizeAnimation2.fromValue = self.textLayer.value(forKey: "fontSize")
            fontSizeAnimation2.toValue = 35
            fontSizeAnimation2.isRemovedOnCompletion = false
            fontSizeAnimation2.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            fontSizeAnimation2.fillMode = CAMediaTimingFillMode.forwards
            self.textLayer.add(fontSizeAnimation2, forKey: nil)
            
            
            self.heartImageView.frame = CGRect(x: 21, y: 78, width: 70, height: 67)
            self.addRepositionAnimation(from: self.heartLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: -14, y: -29), element: self.heartLabel)
            self.scaleFontAnimation(from: 20, to: 24.5, element: self.heartLabel)
            
            self.temperatureImageView.frame = CGRect(x: 150, y: 78, width: 68, height: 67)
            self.addRepositionAnimation(from: self.temperatureLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: 0, y: -29), element: self.temperatureLabel)
            self.scaleFontAnimation(from: 20, to: 24.5, element: self.temperatureLabel)
            
            self.pressureImageView.frame = CGRect(x: 290, y: 77, width: 68, height: 67)
            self.addRepositionAnimation(from: self.pressureLabel.value(forKey: "transform.translation") as Any, to: CGPoint(x: 10, y: 29), element: self.temperatureLabel)
            self.scaleFontAnimation(from: 20, to: 24.5, element: self.pressureLabel)
            
            
            // remove elements
            self.cardSectionSelector.alpha = 0.0
        })
        
        helpTranslationAnimator.startAnimation()
        helpTranslationAnimator.addCompletion({_ in
            self.fadeInMainShadow()
            
            // remove elements
            self.cardSectionSelector.isEnabled = false
            self.heartRateButton.isEnabled = false
            self.temperatureButton.isEnabled = false
            self.pressureButton.isEnabled = false
            
        })
        didExpand = false
    }
    
    private func fadeInMainShadow() {
        let baseView = UIView(frame: CGRect(x: 17, y: 161, width: 380, height: 230))
        baseView.backgroundColor = UIColor.white
        baseView.layer.cornerRadius = 17
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOffset = CGSize(width: 3, height: 3)
        baseView.layer.shadowOpacity = 0.7
        baseView.layer.shadowRadius = 4.0
        baseView.tag = 100
        baseView.alpha = 0
        
        if let _ = view.viewWithTag(100) {
            return
        }
        else if !didExpand {
            view.addSubview(baseView)
            UIView.animate(withDuration: 0.5) {
                baseView.alpha = 1.0
            }
        }
    }
    
    var didLongPress = false
    let minimumPressDuration = 0.75
    var currentDateTime = Date().timeIntervalSinceReferenceDate

    var interactions: [Interaction] = []
    
    private func setupPressDetection() {
        let pressLogger = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        pressLogger.minimumPressDuration = minimumPressDuration
        pressLogger.delaysTouchesBegan = false
        pressLogger.delegate = self as UIGestureRecognizerDelegate
        self.view.addGestureRecognizer(pressLogger)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            // Start of long press (ie tapped+held for > 0.75s)
            if (!didLongPress) {
                print("Pressed at: \(gestureReconizer.location(ofTouch: 0, in: view))")
                print("over \(minimumPressDuration)s")
                didLongPress = true
                currentDateTime = Date().timeIntervalSinceReferenceDate
                
                showHelp()
            }
        }
        else {
            // End of long press
            let pressDuration = Date().timeIntervalSinceReferenceDate - currentDateTime + minimumPressDuration
            let pressLocation = gestureReconizer.location(ofTouch: 0, in: view)
            let press = Interaction(location: pressLocation, tapType: .press, durationInSeconds: pressDuration)
            interactions.append(press)
            
            didLongPress = false
            print(pressDuration)
            print("end of long press")
        }
    }
    
    @objc private func showHelp() {
        
        if isShowingHelp {
            return
        }
        
        isShowingHelp = true
        
        insertBlurBackground()
        insertHelpImageView()
        insertCloseButton()
        
        // Shadow view tag
        if let _ = view.viewWithTag(100) {
            view.bringSubviewToFront(view.viewWithTag(100)!)
        }
        
        view.bringSubviewToFront(yourHealthCard)
        
        if !didExpand {
            // setup tap region
            let resumeButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 421))
            resumeButton.setTitle("", for: .normal)
            resumeButton.backgroundColor = .clear
            resumeButton.addTarget(self, action: #selector(tappedResumeButton), for: [.touchUpInside, .touchDragEnter, .touchDragInside])
            view.addSubview(resumeButton)
            view.bringSubviewToFront(resumeButton)
            helpSubViews.append(resumeButton)
        }
        
        helpTranslationAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: {
            self.yourHealthCard.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(translationX: 0, y: 20))
            self.view.viewWithTag(100)?.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(translationX: 0, y: 20))
            
            // Adding haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        })
        helpTranslationAnimator.startAnimation()
    }
    
    @objc func tappedResumeButton(_ button: UIButton = UIButton(), forEvent event: UIEvent = UIEvent()) {
        isShowingHelp = false
        
        for subview in helpSubViews {
            subview.removeFromSuperview()
        }
        
        // animate focus view back
        helpTranslationAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.53, animations: {
            self.yourHealthCard.transform = CGAffineTransform.identity
            self.view.viewWithTag(100)?.transform = CGAffineTransform.identity
        })
        
        helpTranslationAnimator.startAnimation()
        self.touchUp()
    }
    
    private func insertBlurBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        helpSubViews.append(blurEffectView)
    }
    
    private func insertHelpImageView() {
        helpImageView.image = UIImage(named: "Group 8")
        view.addSubview(helpImageView)
        helpSubViews.append(helpImageView)
    }
    
    private func insertCloseButton() {
        // insert button
        helpCloseButton.setImage(UIImage(named: "Group 12"), for: .normal)
        helpCloseButton.addTarget(self, action:#selector(self.helpCloseButtonTapped), for: .touchUpInside)
        view.addSubview(helpCloseButton)
        helpSubViews.append(helpCloseButton)
        
        // insert label
        let closeButtonLabel = UILabel(frame: CGRect(x: 160, y: 654, width: 95, height: 36))
        closeButtonLabel.text = "Close"
        closeButtonLabel.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.bold)
        closeButtonLabel.textColor = UIColor(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1.0)
        view.addSubview(closeButtonLabel)
        helpSubViews.append(closeButtonLabel)
    }
    
    @objc func helpCloseButtonTapped() {
        // remove all help subviews
        for subview in helpSubViews {
            subview.removeFromSuperview()
        }
        
        // animate focus view back
        helpTranslationAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.53, animations: {
            self.yourHealthCard.transform = CGAffineTransform.identity
            self.view.viewWithTag(100)?.transform = CGAffineTransform.identity
        })
        
        helpTranslationAnimator.startAnimation()
        
        helpTranslationAnimator.addCompletion({_ in
            self.fadeInMainShadow()
            self.isShowingHelp = false
        })
    }
}
