//
//  Evaluator.swift
//  λcalculus
//
//  Created by Toni Kocjan on 06/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

//
// Calculate a result from the application of a function to an expression.
//
//
// Examples:
//
// ((λx.x)x) -> x
// (((λx.(λy.x))x)y) -> x
// (((\x.(\y.x))(\x.(\y.x)))(\x.(\y.y))) -> "λx.λy.x"
// (((\x.(\y.y))(\x.(\y.x)))(\x.(\y.y))) -> λx.λy.y
// ...
//

enum Status {
  case resolved(Tree)
  case pending
}

typealias SymbolTable = [String: Status]

extension Dictionary {
  func updatingValue(_ value: Value, forKey key: Key) -> Self {
    var copy = self
    copy[key] = value
    return copy
  }
}

func betaConversion(_ tree: Tree, table: SymbolTable = [:]) -> (Tree, SymbolTable) {
  func evaluateVariable(name: String, table: SymbolTable) -> Tree {
    table[name].flatMap {
      switch $0 {
      case .pending:
        return nil
      case .resolved(let tree):
        return tree
      }
      } ?? .variable(name: name)
  }
  
  func evaluateExpression(_ tree: Tree, table: SymbolTable) -> (Tree, SymbolTable) {
    switch tree {
    case .abstraction(let v, let e):
      let (e, t) = evaluateExpression(e, table: table.updatingValue(.pending, forKey: v))
      return (.abstraction(variable: v, expression: e), t)
    case .application(.abstraction(let v, let e), let e1):
      let (e2, t2) = evaluateExpression(e1, table: table)
      let (e3, t3) = evaluateExpression(e, table: t2.updatingValue(.resolved(e2), forKey: v))
      return (e3, t3)
    case .application(let f, let e):
      let (f1, t1) = evaluateExpression(f, table: table)
      let (e2, t2) = evaluateExpression(e, table: t1)
      return (.application(fn: f1, value: e2), table: t2)
    case .variable(let v):
      return (evaluateVariable(name: v, table: table), table)
    }
  }
  
  let (tree, table) = evaluateExpression(tree, table: [:])
  switch tree {
  case .application:
    return betaConversion(tree, table: table)
  default:
    return (tree, table)
  }
}
