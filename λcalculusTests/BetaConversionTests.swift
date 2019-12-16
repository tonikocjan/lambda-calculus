//
//  BetaConversionTests.swift
//  λcalculusTests
//
//  Created by Toni Kocjan on 06/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import XCTest

class BetaConversionTests: XCTestCase {
  func testBetaConversion() {
    XCTAssertTrue(successBetaTest(expression: #"((\x.x)a)"#, expected: "a"))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.x))a)b)"#, expected: "a"))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.y))a)b)"#, expected: "b"))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.x))(\x.(\y.x)))(\x.(\y.y)))"#, expected: #"λx.λy.x"#))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.y))(\x.(\y.x)))(\x.(\y.y)))"#, expected: #"λx.λy.y"#))

    XCTAssertTrue(successBetaTest(expression: #"(xx)"#, expected: #"(x x)"#))
    XCTAssertTrue(successBetaTest(expression: #"(c(xx))"#, expected: #"(c (x x))"#))

    XCTAssertTrue(successBetaTest(expression: #"((\x.(\y.(x(\z.(xx)))))a)"#, expected: "λy.(a λz.(a a))"))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.(x(\z.(xx)))))a)b)"#, expected: "(a λz.(a a))"))
    XCTAssertTrue(successBetaTest(expression: #"(((\x.(\y.(x((\z.(xx))c))))a)b)"#, expected: "(a (a a))"))

//    XCTAssertTrue(successTest(expression: #"((\x.(xx))(\x.(xx)))"#, expected: "(λx.(x x) λx.(x x))"))

    // need to rename free variable so it does not become bound!
    XCTAssertTrue(successBetaTest(expression: #"((\y.\x.y)x)"#, expected: "λx.x1"))
    XCTAssertTrue(successBetaTest(expression: #"((\f.\x.(fx))(\f.\x.(fx)))"#, expected: "λx.λx1.(x x1)"))
    
//    XCTAssertTrue(successTest(expression: #"((\f.\x.(fx))(\f.\x.(fx)))"#, expected: "kkk"))
    
    XCTAssertTrue(successBetaTest(expression: #"(((\x.\y.((+x)y))2)3)"#, expected: "5.0"))
  }
  
  func testInterpreter() {
    XCTAssertTrue(successInterpreterTest(expression: #"""
    let t = \x.\y.x
    let f = \x.\y.y
    let o = \a.\b.((aa)b)
    let l = ((+2)3)
    let r = ((/2)0)
    ((((ot)t)l)r)
    """#, expected: "5.0"))
    
    XCTAssertTrue(successInterpreterTest(expression: #"""
    let t = \x.\y.x
    let f = \x.\y.y
    let o = \a.\b.((aa)b)
    let l = ((+2)3)
    let r = ((/2)0)
    ((((of)f)l)r)
    """#, expected: "inf"))
    
    // Product (a * b)
    // T = Tuple constructor
    // F = first (a, _)
    // S = second (_, b)
    XCTAssertTrue(successInterpreterTest(expression: #"""
    let T = \e.\m.\g.((ge)m)
    let F = \h.(h(\a.\b.a))
    let S = \i.(i(\c.\d.d))

    let x = ((T2)5)
    (Fx)
    (Sx)
    """#, expected: "2.0, 5.0"))
    
    // Either (Left | Right)
    // L = Left constructor
    // R = Right constructor
    XCTAssertTrue(successInterpreterTest(expression: #"""
    let L = \f.\g.\x.\y.(fx)
    let R = \f.\g.\x.\y.(gy)

    let Q = \a.((+a)8)
    let Y = \a.((+a)100)

    let p = ((((LQ)Y)2)5)
    let l = ((((RQ)Y)2)5)
    p
    l
    """#, expected: "10.0, 105.0"))
    
    // Bool (True | False) implemented using Either (Left | Right)
    XCTAssertTrue(successInterpreterTest(expression: #"""
    let L = \f.\g.\x.\y.(fx)
    let R = \l.\m.\j.\k.(mk)

    let p = ((L2)5)
    let l = ((R2)5)

    let i = \q.q

    let T = ((Li)i)
    let F = ((Ri)i)

    let O = \a.\b.((aa)b)
    ((OT)F)
    ((OF)F)
    """#, expected: "λx.λy.x, λj.λk.k"))
  }
}

private extension BetaConversionTests {
  func successBetaTest(expression: String, expected: String) -> Bool {
    let parser = lambdaExpressionParser()
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map { betaConversion($0) }
      .map { $0.0 }
      .map { $0.description == expected }
    if !didPass! {
      parse(parser, input: expression)
      .map { $0.0 }
      .map { betaConversion($0) }
      .map { $0.0 }
      .map { print($0.description, expected) }
    }
    return didPass ?? false
  }
  
  func successInterpreterTest(expression: String, expected: String) -> Bool {
    let parser = programParser()
    let expected = "[" + expected + "]"
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map { interpret(program: $0) }
      .map { $0.description == expected }
    if !didPass! {
      parse(parser, input: expression)
      .map { $0.0 }
      .map { interpret(program: $0) }
      .map { print($0.description, expected) }
    }
    return didPass ?? false
  }
}
