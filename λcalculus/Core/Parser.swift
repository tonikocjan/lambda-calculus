//
//  Parser.swift
//  λcalculus
//
//  Created by Toni Kocjan on 04/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

typealias Parser<T> = (String) -> (T, String)?
typealias Predicate<T> = (T) -> Bool

func parse<T>(_ parser: Parser<T>, input: String) -> (T, String)? { parser(input) }

precedencegroup FishOperatorPrecedence {
  associativity: left
}
infix operator >>=: FishOperatorPrecedence
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

infix operator +++: FishOperatorPrecedence
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

let isDigit = sat { $0.isNumber }
let isLower = sat { $0.isLowercase }
let isUppercase = sat { $0.isUppercase }
let isLetter = sat { $0.isLetter }
let isChar = { char in sat { $0 == char } }
let isOpeningBracket = isChar("(")
let isClosingBracket = isChar(")")
let isLambda = isChar("\\")
let isDot = isChar(".")

func notEmpty<T>(_ parser: @escaping Parser<T>) -> Parser<T> {
  { input in
    if input.isEmpty { return nil }
    return parser(input)
  }
}

func lambdaExpressionParser() -> Parser<Tree> {
  var id = 0
  
  func lambdaExpression() -> Parser<Tree> {
    (isLetter >>= { letter in
      identity(.variable(id: id, name: String(letter)))
    })
      +++ (isOpeningBracket >>= { _ in
        (isLambda >>= { _ in
          abstraction() >>= { a in
            isClosingBracket >>= { _ in
              identity(a)
            }}
          })
          +++ (application() >>= { a in
            isClosingBracket >>= { _ in
              identity(a)
            }})
        })
      +++ (isLambda >>= { _ in
        abstraction() >>= { a in
          lambdaExpression() >>= { e in
            identity(.application(id: 0, fn: a, value: e))
            }
            +++ identity(a)
        }})
//      +++ application()
  }
  
  func abstraction() -> Parser<Tree> {
    isLetter >>= { letter in
      isDot >>= { _ in
        lambdaExpression() >>= { expression in
          identity(.abstraction(id: id,
                                variable: String(letter),
                                expression: expression))
        }
      }
    }
  }
  
  func application() -> Parser<Tree> {
    lambdaExpression() >>= { e1 in
      lambdaExpression() >>= { e2 in
        identity(.application(id: id, fn: e1, value: e2))
      }
    }
  }
  
  return lambdaExpression()
}
