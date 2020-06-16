//
//  YourHealthSelection.swift
//  shrinkAnimation
//
//  Created by Pranav Paul on 13/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

enum YourHealthSelection: CaseIterable {
    case heartRate
    case skinTemperature
    case bloodPressure
}

struct YourHealthSelectorPositions {
    
    let heartFrame: CGRect = CGRect(x: 22, y: 100, width: 90, height: 139)
    let temperatureFrame: CGRect = CGRect(x: 112, y: 100, width: 140, height: 139)
    let bloodPressureFrame: CGRect = CGRect(x: 257, y: 100, width: 105, height: 139)
}
