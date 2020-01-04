//
//  main.swift
//  λcalculus
//
//  Created by Toni Kocjan on 04/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

var program = #"""
let a = \x.\y.x
((a((+5)10))((/2)0))  
"""#

parse(programParser(), input: program)
  .map { $0.0 }
  .map(interpret)
  .map { print($0) } ?? print("error")

func readLines() -> String {
  var lines = [String]()
  while let line = readLine() {
    lines.append(line)
  }
  return lines.joined(separator: "\n")
}

//let program = readLines()
//parse(programParser(), input: program)
//  .map { $0.0 }
//  .map(interpret)
//  .map { print($0) } ?? print("error")
