//
//  Interaction.swift
//  shrinkAnimation
//
//  Created by Pranav Paul on 10/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

enum InteractionType {
    case tap
    case press
}

struct Interaction {
    let location: CGPoint
    let tapType: InteractionType
    let durationInSeconds: Double
}
