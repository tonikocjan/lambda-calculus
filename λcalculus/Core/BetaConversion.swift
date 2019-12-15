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
    case .variable, .constant:
      return []
    case .application(let l, let r):
      return boundVariables(in: l) + boundVariables(in: r)
    case .abstraction(let v, let e):
      return [v] + boundVariables(in: e)
    }
  }
  
  func evaluateExpression(_ tree: Tree, env: Environment) -> (Tree, Environment) {
    switch tree {
    case .variable(let v):
      return (evaluateVariable(name: v, env: env), env)
    case .abstraction(let v, let e):
      let (e, t) = evaluateExpression(e, env: env.updatingValue(.pending, forKey: v))
      return (.abstraction(variable: v, expression: e), t)
    case .application(let f, let e):
      switch evaluateExpression(f, env: env) {
      case (.abstraction(let v, let b), let env):
        let (e1, t1) = evaluateExpression(e, env: env)
        let (e1AfterAlpha, _) = alphaReduction(b, e1)
        let (e2, t2) = evaluateExpression(b, env: t1.updatingValue(.resolved(e1AfterAlpha), forKey: v))
        return (e2, t2)
      case let (left, env):
        let (right, t1) = evaluateExpression(e, env: env)
        return (.application(fn: left, value: right), t1)
      }
    case .constant:
      return (tree, env)
    }
  }
  
  func alphaReduction(_ left: Tree,_ right: Tree) -> (Tree, Bool) {
    switch (left, right) {
    case (.abstraction(let v, _), .variable(let arg)) where v == arg:
      return (.variable(name: renameVariable(arg)), true)
    case (.abstraction(_, let b), .variable):
      return alphaReduction(b, right)
    case _:
      return (right, false)
    }
  }
  
  func renameVariable(_ name: String) -> String {
    switch name.last?.isNumber {
    case true?:
      let count = Int(String(name.last!)).map { $0 + 1 } ?? 0
      return String(name.dropLast()) + String(count)
    case false?:
      return name + "1"
    case nil:
      fatalError("Empty name!")
    }
  }
  
  return evaluateExpression(tree, env: env)
}
