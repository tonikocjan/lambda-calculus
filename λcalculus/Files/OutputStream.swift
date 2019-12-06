//
//  OutputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol OutputStream {
  func print(_ string: String)
  func printLine(_ string: String)
}
