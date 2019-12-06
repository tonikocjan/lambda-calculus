//
//  Generator.swift
//  λcalculus
//
//  Created by Toni Kocjan on 05/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

func λexpressionsGenerator(depth: Int) -> [Tree] {
  if depth == 1 {
    return [.variable(name: "x"),
            .application(fn: .variable(name: "x"), value: .variable(name: "x")),
            .abstraction(variable: "x", expression: .variable(name: "x"))]
  }
  
  let a = λexpressionsGenerator(depth: depth - 1).map { Tree.abstraction(variable: "x", expression: $0) }
  let b = λexpressionsGenerator(depth: depth - 1).map { Tree.application(fn: $0, value: .variable(name: "x")) }
  let d = λexpressionsGenerator(depth: depth - 1)
  return [a, b, d].flatMap { $0 }
}
