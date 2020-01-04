//
//  Evaluator.swift
//  λcalculus
//
//  Created by Toni Kocjan on 06/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

enum Status {
  case resolved(Tree)
  case pending
}

typealias Environment = [String: (Tree, Bool)]

extension Dictionary {
  func updatingValue(_ value: Value, forKey key: Key) -> Self {
    var copy = self
    copy[key] = value
    return copy
  }
  
  func removingValue(forKey key: Key) -> Self {
    var copy = self
    copy[key] = nil
    return copy
  }
}

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

// for now, it is assumed that there are no name colisions
func betaConversion(_ tree: Tree, env: Environment = [:]) -> (Tree, Environment) {
  func evaluateVariable(name: String, env: Environment) -> (Tree, Environment) {
    let evaluated: (Tree, Environment) = env[name].flatMap { (tree, isEvaluated) in
      switch isEvaluated {
      case true:
        return (tree, env)
      case false:
        if case let .variable(v) = tree, v == name {
          return (tree, env.updatingValue((tree, true), forKey: name))
        }
        let reduced = betaConversion(tree, env: env).0
        return (reduced, env.updatingValue((reduced, true), forKey: name))
      }
    } ?? (.variable(name: name), env)
    return evaluated
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
      let evaled = evaluateVariable(name: v, env: env)
      return evaled
    case .abstraction(let v, let e):
      let (e, t) = evaluateExpression(e, env: env.removingValue(forKey: v))
      return (.abstraction(variable: v, expression: e), t)
    case .application(let f, let e):
      switch evaluateExpression(f, env: env) {
      case (.abstraction(let v, let b), let env):
        let (e2, t2) = evaluateExpression(b, env: env.updatingValue((e, false), forKey: v))
        return (e2, t2)
      case let (left, env):
        let (right, t1) = evaluateExpression(e, env: env)
        
        // check if current expr is an application of an application of a built-in operator (+, -, *, /, =)
        // if it is, we can replace the application with evaluated value
        switch (left, right) {
        case (.application(fn: .variable(name: "+"), .constant(value: let l)), .constant(let r)):
          return (.constant(value: l + r), env)
        case (.application(fn: .variable(name: "-"), .constant(value: let l)), .constant(let r)):
          return (.constant(value: l - r), env)
        case (.application(fn: .variable(name: "*"), .constant(value: let l)), .constant(let r)):
          return (.constant(value: l * r), env)
        case (.application(fn: .variable(name: "/"), .constant(value: let l)), .constant(let r)):
          if r == 0 { fatalError() }
          return (.constant(value: l / r), env)
        case (.application(fn: .variable(name: "="), .constant(value: let l)), .constant(let r)):
          if l == r {
            return (.abstraction(variable: "1", expression: .abstraction(variable: "2", expression: .variable(name: "1"))), env)
          }
          return (.abstraction(variable: "1", expression: .abstraction(variable: "2", expression: .variable(name: "2"))), env)
        case _:
          return (.application(fn: left, value: right), t1)
        }
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


//
// Executes the given program using `beta-conversion` mechanism:
//
// for every `binding` the environment gets updated with the result of the expression
// we can therefore reference λexpressions from previous lines in the next:
//
// '''
// T = λx.λy.x
// F = λx.λy.y
// OR = λa.λb.a T (b T F)
// '''
//
// the output is a list of beta-converted expressions for each `Line.execute`
//
func interpret(program: Program) -> [Tree] {
  program.reduce((Environment(), [Tree]())) { (arg0, l) in
    let (env, acc) = arg0
    switch l {
    case .execute(let e):
      let (e1, env) = betaConversion(e, env: env)
      return (env, acc + [e1])
    case .binding(let v, let e):
      return (env.updatingValue((e, false), forKey: v), acc)
    }
  }.1
}
