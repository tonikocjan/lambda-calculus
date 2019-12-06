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
    return [.variable(id: 0, name: "x"),
            .application(id: 0, fn: .variable(id: 0, name: "x"), value: .variable(id: 0, name: "x")),
            .abstraction(id: 0, variable: "x", expression: .variable(id: 0, name: "x"))]
  }
  
  let a = λexpressionsGenerator(depth: depth - 1).map { Tree.abstraction(id: 0, variable: "x", expression: $0) }
  let b = λexpressionsGenerator(depth: depth - 1).map { Tree.application(id: 0, fn: $0, value: .variable(id: 0, name: "x")) }
  let d = λexpressionsGenerator(depth: depth - 1)
  return [a, b, d].flatMap { $0 }
}
