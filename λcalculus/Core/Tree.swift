//
//  Tree.swift
//  λcalculus
//
//  Created by Toni Kocjan on 05/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

indirect enum Tree {
  case variable(name: String)
  case abstraction(variable: String, expression: Tree)
  case application(fn: Tree, value: Tree)
  case constant(value: Double)
}

extension Tree: CustomStringConvertible {
  var description: String {
    func stringRepresentation(_ tree: Tree) -> String {
      switch tree {
      case .variable(let name):
        return name
      case .application(let fn, let value):
        return "(" + stringRepresentation(fn) + " " + stringRepresentation(value) + ")"
      case .abstraction(let variable, let expr):
        return "λ" + variable + "." + stringRepresentation(expr)
      case .constant(let value):
        return String(value)
      }
    }
    
    return stringRepresentation(self)
  }
  
  var treeLikeDescription: String {
    func withIndent(_ string: String, indent: Int) -> String { String(repeating: " ", count: indent) + string }
    
    var indent = 0
    func stringRepresentation(_ tree: Tree) -> String {
      switch tree {
      case .variable(let name):
        return withIndent(name, indent: indent)
      case .application(let fn, let value):
        indent += 2
        let application = withIndent("@\n", indent: indent - 2) + stringRepresentation(fn) + "\n" + stringRepresentation(value)
        indent -= 2
        return application
      case .abstraction(let variable, let expr):
        indent += 2
        let abstraction = withIndent("λ\(variable).", indent: indent - 2) + "\n" + stringRepresentation(expr)
        indent -= 2
        return abstraction
      case .constant(let value):
        return withIndent(String(value), indent: indent)
      }
    }
    
    return stringRepresentation(self)
  }
}

extension Tree: Equatable {
  static func == (lhs: Tree, rhs: Tree) -> Bool {
    switch (lhs, rhs) {
    case (.variable(let v1), .variable(let v2)):
      return v1 == v2
    case (.application(let f1, let e1), .application(let f2, let e2)):
      return f1 == f2 && e1 == e2
    case (.abstraction(let v1, let e1), .abstraction(let v2, let e2)):
      return v1 == v2 && e1 == e2
    case _:
      return false
    }
  }
}
