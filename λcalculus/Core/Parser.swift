//
//  Parser.swift
//  λcalculus
//
//  Created by Toni Kocjan on 04/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

typealias Parser<T> = (String) -> (T, String)?

func parse<T>(_ parser: Parser<T>, input: String) -> (T, String)? { parser(input) }

precedencegroup BindOperatorPrecedence {
  associativity: left
}
infix operator >>=: BindOperatorPrecedence
func >>=<A, B>(_ parser: @escaping Parser<A>, _ f: @escaping ((A) -> Parser<B>)) -> Parser<B> {
  {
    switch parse(parser, input: $0) {
    case let (x, text)?:
      return parse(f(x), input: text)
    case nil:
      return nil
    }
  }
}

infix operator +++: BindOperatorPrecedence
func +++<T>(_ parser: @escaping Parser<T>, _ failure: @escaping Parser<T>) -> Parser<T> {
  {
    switch parse(parser, input: $0) {
    case .some(let parsed):
      return parsed
    case nil:
      return parse(failure, input: $0)
    }
  }
}

func identity<T>(_ x: T) -> Parser<T> {
  { (x, $0) }
}

func firstCharacter() -> Parser<Character> {
  { input in
    input.first.map { ($0, String(input.dropFirst())) }
  }
}

func failure<T>() -> Parser<T> {
  { _ in nil }
}

func failure<T>(_ parser: Parser<T>) -> Parser<T> {
  { _ in nil }
}

func sat(_ p: @escaping Predicate<Character>) -> Parser<Character> {
  firstCharacter() >>= { char in
    if p(char) { return identity(char) }
    return failure()
  }
}

var isDigit = sat { $0.isNumber }
let isLower = sat { $0.isLowercase }
let isUppercase = sat { $0.isUppercase }
let isLetter = sat { $0.isLetter }
let isChar = { char in sat { $0 == char } }
let isOpeningBracket = isChar("(")
let isClosingBracket = isChar(")")
let isLambda = isChar("\\")
let isDot = isChar(".")
let isEqual = isChar("=")
let isWhitespace = sat { $0.isWhitespace }

func notEmpty<T>(_ parser: @escaping Parser<T>) -> Parser<T> {
  { input in
    if input.isEmpty { return nil }
    return parser(input)
  }
}

// Parses λexpressions with the following grammar:
//
// Λ ::= variable | abstraction | application | constant
// variable ::= any character that is not one of {'.', 'λ', '(', ')'} and not number // TODO: - extend the grammar to support multi-character names with decimals
// abstraction ::= λvariable.Λ
// application ::= Λ Λ
// constant ::= (0..9)constant'
// constant' ::= (0..9)constant' | end
//
// expressions can be wrapped with `(` and `)` when ambiguity is possible
//
func lambdaExpressionParser() -> Parser<Tree> {
  func lambdaExpression() -> Parser<Tree> {
    (variableParser() >>= { letter in
      // found valid identifier
      identity(.variable(name: String(letter)))
    })
      +++ (constantParser() >>= {
        // found valid constant
        identity(Tree.constant(value: $0))
        })
      +++ (isOpeningBracket >>= { _ in
        // expression starts with a `(`
        (isLambda >>= { _ in
          // found λ, parse `abstraction`
          abstraction() >>= { a in
            isClosingBracket >>= { _ in
              identity(a)
            }}
          })
          // otherwise parse `application`
          +++ (application() >>= { a in
            isClosingBracket >>= { _ in
              identity(a)
            }})
        })
      
      // this is an attempt to extend the grammar to allow parsing expressions without
      // wrapping them with `()`:
      //
      // (λx.x) -> λx.x
      // (λx.(λy.x)) -> λx.λy.x
      //
      // application is not yet supported:
      // (xx) -> xx
      //
      +++ (isLambda >>= { _ in
        abstraction() >>= { a in
          lambdaExpression() >>= { e in
            identity(.application(fn: a, value: e))
            }
            +++ identity(a)
        }})
//      +++ application() // not working <= infinite recursion .. 🤔
  }
  
  func abstraction() -> Parser<Tree> {
    variableParser() >>= { letter in
      isDot >>= { _ in
        lambdaExpression() >>= { expression in
          identity(.abstraction(variable: String(letter),
                                expression: expression))
        }
      }
    }
  }
  
  func application() -> Parser<Tree> {
    lambdaExpression() >>= { e1 in
      lambdaExpression() >>= { e2 in
        identity(.application(fn: e1, value: e2))
      }
    }
  }


  func constantParser() -> Parser<Double> {
    func parser(_ firstChar: Character) -> Parser<Double> {
      {
        var input = $0
        var number = String(firstChar)
        while true {
          if let char = input.first, char.isNumber {
            number += String(char)
            input = String(input.dropFirst())
          } else {
            return Double(number).map { ($0, input) }
          }
        }
      }
    }
    return isDigit >>= parser
  }
  
  func variableParser() -> Parser<String> {
    let notValidCharacters = ".\\() 0123456789\n"
    let validIdentifierParser = sat { !notValidCharacters.contains($0) }
    return validIdentifierParser >>= { identity(String($0)) }
  }

  
  return lambdaExpression()
}

///

//
// A line in a program is either
//   1. binding: let v = λexpression
//   2. execution: λexpression
//
enum Line {
  case binding(v: String, e: Tree)
  case execute(e: Tree)
}

typealias Program = [Line]

func ignoreSpaces<T>(_ parser: @escaping Parser<T>) -> Parser<T> {
  func skipWhiteSpace() -> Parser<()> {
//    isWhitespace >>= { _ in
//      skipWhiteSpace()
//    }
    {
      var input = $0
      while input.first.map({ $0.isWhitespace }) ?? false {
        input = String(input.dropFirst())
      }
      return ((), input)
    }
  }
  return skipWhiteSpace() >>= { parser }
}

// Parses programs that are formed with the following syntax:
//
// program ::= line program | end
// line ::= binding | execution
// binding ::= let id = λexpression
// id ::= (0..9)id | (a..z)id | (A..Z)id | end
// execution = λexpression
//
// note that we can freely add spaces around terms:
// let x = λa.a
// is equivalent to
// let    x   = λa.a
//
// The result is a list of `Line`s
//
func programParser() -> Parser<Program> {
  // parses `let` keyword
  let letParser: Parser<()> = ignoreSpaces { input in
    guard input.count >= 3 else { return nil }
    let skip = input.index(input.startIndex, offsetBy: 3)
    if input.starts(with: "let") { return ((), String(input[skip...])) }
    return nil
  }

  // parses an identifier
  let identifierParser: Parser<String> = ignoreSpaces { input in
    input
      .firstIndex(where: { !($0.isLetter || $0.isNumber) })
      .map { (String(input[..<$0]), String(input[$0...])) }
    ?? (input, "")
  }
  
  // parses a binding
  let bindingParser: Parser<Line> =
    letParser >>= {
      identifierParser >>= { identifier in
        ignoreSpaces(isEqual) >>= { _ in
          ignoreSpaces(lambdaExpressionParser()) >>= { e in
            identity(.binding(v: identifier, e: e))
          }
        }
      }
  }
  
  // parses an execution statement
  let executeParser: Parser<Line> =
    ignoreSpaces(lambdaExpressionParser()) >>= { e in
      identity(.execute(e: e))
  }
  
  // the actual `Program` parser
  func parser() -> Parser<Program> {
    bindingParser >>= ({ binding in
      ignoreSpaces(parser()) >>= { lines in
        identity([binding] + lines)
        }
        +++ identity([binding])
    })
      +++ (executeParser >>= { e in
        ignoreSpaces(parser()) >>= { lines in
          identity([e] + lines)
          } +++ identity([e])
        })
  }
  
  return parser()
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
// the output is a list of beta-converted expressions for each `Line.execute` line
//
func interpret(program: Program) -> [Tree] {
  program.reduce((Environment(), [Tree]())) { (arg0, l) in
    let (env, acc) = arg0
    switch l {
    case .execute(let e):
      let (e1, env) = betaConversion(e, env: env)
      return (env, acc + [e1])
    case .binding(let v, let e):
      let (e1, env) = betaConversion(e, env: env)
      return (env.updatingValue(.resolved(e1), forKey: v), acc)
    }
  }.1
}

extension Line: Equatable {
  static func == (lhs: Line, rhs: Line) -> Bool {
    switch (lhs, rhs) {
    case (.binding(let v1, let e1), .binding(let v2, let e2)):
      return v1 == v2 && e1 == e2
    case (.execute(let e1), .execute(let e2)):
      return e1 == e2
    case _:
      return false
    }
  }
}
