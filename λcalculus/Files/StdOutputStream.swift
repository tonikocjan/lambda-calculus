//
//  StdOutputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 18/10/2019.
//  Copyright © 2019 Toni Kocjan. All rights reserved.
//

import Foundation

public class StdOutputStream: OutputStream {
  public func print(_ string: String) {
    Swift.print(string, terminator: "")
  }
  
  public func printLine(_ string: String) {
    Swift.print(string)
  }
}
