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

typealias Environment = [String: Status]

extension Dictionary {
  func updatingValue(_ value: Value, forKey key: Key) -> Self {
    var copy = self
    copy[key] = value
    return copy
  }
}

// for now, it is assumed that there are no no name colisions
func betaConversion(_ tree: Tree, env: Environment = [:]) -> (Tree, Environment) {
  func evaluateVariable(name: String, env: Environment) -> Tree {
    env[name].flatMap {
      switch $0 {
      case .pending:
        return nil
      case .resolved(let tree):
        return tree
      }
      } ?? .variable(name: name)
  }
  
  func boundVariables(in tree: Tree) -> [String] {
    switch tree {
    case .variable:
      return []
    case .application(let l, let r):
      return boundVariables(in: l) + boundVariables(in: r)
    case .abstraction(let v, let e):
      return [v] + boundVariables(in: e)
    }
  }
  
//  func rename(v: String, taken: [String]) -> String {
//    func newName(v: String) -> String {
//      let withoutLast = String(v.dropLast())
//      return v.last
//        .flatMap { Int(String($0)) }
//        .map { withoutLast + String($0 + 1) }
//      ?? v + "1"
//    }
//    let newV = newName(v: v)
//    if taken.contains(newV) { return rename(v: newV, taken: taken) }
//    return newV
//  }
  
  func evaluateExpression(_ tree: Tree, env: Environment) -> (Tree, Environment) {
    switch tree {
    case .variable(let v):
      return (evaluateVariable(name: v, env: env), env)
    case .abstraction(let v, let e):
      let (e, t) = evaluateExpression(e, env: env.updatingValue(.pending, forKey: v))
      
//      switch e {
//      case .application(.abstraction(let v1, let e1), let e2):
//        let abstraction = Tree.abstraction(variable: v1, expression: e1)
//        let bound = boundVariables(in: abstraction)
//        if bound.contains(v) {
//          let newName = rename(v: v, taken: bound)
//          let (e, c) = alphaConversion(e, mapping: [v: newName])
//          return (.application(fn: .abstraction(variable: v, expression: e), value: e2), t)
//        }
//        return (e, t)
//      case _:
        return (.abstraction(variable: v, expression: e), t)
//      }
    case .application(let f, let e):
      switch evaluateExpression(f, env: env) {
      case (.abstraction(let v, let b), let env):
        let (e1, t1) = evaluateExpression(e, env: env)
        let (e2, t2) = evaluateExpression(b, env: t1.updatingValue(.resolved(e1), forKey: v))
        return (e2, t2)
      case let (left, env):
        let (right, t1) = evaluateExpression(e, env: env)
        return (.application(fn: left, value: right), t1)
      }
    }
  }
  
  return evaluateExpression(tree, env: env)
}
