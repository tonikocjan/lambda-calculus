//
//  Tree.swift
//  λcalculus
//
//  Created by Toni Kocjan on 05/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

indirect enum Tree {
  case variable(id: Int, name: String)
  case abstraction(id: Int, variable: String, expression: Tree)
  case application(id: Int, fn: Tree, value: Tree)
}

extension Tree: CustomStringConvertible {
  var description: String {
    func stringRepresentation(_ tree: Tree) -> String {
      switch tree {
      case .variable(_, let name):
        return name
      case .application(_, let fn, let value):
        return "(" + stringRepresentation(fn) + " " + stringRepresentation(value) + ")"
      case .abstraction(_, let variable, let expr):
        return "λ" + variable + "." + stringRepresentation(expr)
      }
    }
    
    return stringRepresentation(self)
  }
  
  var treeLikeDescription: String {
    func withIndent(_ string: String, indent: Int) -> String { String(repeating: " ", count: indent) + string }
    
    var indent = 0
    func stringRepresentation(_ tree: Tree) -> String {
      switch tree {
      case .variable(let id, let name):
        return withIndent("(\(id))" + name, indent: indent)
      case .application(let id, let fn, let value):
        indent += 2
        let application = withIndent("(\(id))" + "β\n", indent: indent - 2) + stringRepresentation(fn) + "\n" + stringRepresentation(value)
        indent -= 2
        return application
      case .abstraction(let id, let variable, let expr):
        indent += 2
        let abstraction = withIndent("(\(id))" + "λ\(variable).", indent: indent - 2) + "\n" + stringRepresentation(expr)
        indent -= 2
        return abstraction
      }
    }
    
    return stringRepresentation(self)
  }
}
