//
//  AlphaConversion.swift
//  λcalculus
//
//  Created by Toni Kocjan on 07/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

func alphaConversion(_ tree: Tree) -> (Tree, [String: String]) {
  func traceVariableChange(_ v: String, mapping: [String: String]) -> String {
    var mapped = v
    while true {
      if let m = mapping[mapped] { mapped = m }
      else { break }
    }
    return mapped
  }
  
  func variable(_ v: String, mapping: [String: String]) -> String { traceVariableChange(v, mapping: mapping) }

  func conversion(_ tree: Tree, mapping: [String: String]) -> (Tree, [String: String]) {
    switch tree {
    case .variable(let v):
      let v = variable(v, mapping: mapping)
      return (.variable(name: v), mapping)
    case .application(let f, let e):
      let (f1, m1) = conversion(f, mapping: mapping)
      let (e1, m2) = conversion(e, mapping: m1)
      return (.application(fn: f1, value: e1), m2)
    case .abstraction(let v, let e):
      let v = variable(v, mapping: mapping)
      let (e1, m1) = conversion(e, mapping: mapping.updatingValue(v + "'", forKey: v))
      return (.abstraction(variable: v, expression: e1), m1)
    }
  }
  
  return conversion(tree, mapping: [:])
}
