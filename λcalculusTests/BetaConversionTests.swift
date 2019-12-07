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
    XCTAssertTrue(successTest(expression: #"((\x.x)a)"#, expected: "a"))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.x))a)b)"#, expected: "a"))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.y))a)b)"#, expected: "b"))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.x))(\x.(\y.x)))(\x.(\y.y)))"#, expected: #"λx.λy.x"#))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.y))(\x.(\y.x)))(\x.(\y.y)))"#, expected: #"λx.λy.y"#))
    
    XCTAssertTrue(successTest(expression: #"(xx)"#, expected: #"(x x)"#))
    XCTAssertTrue(successTest(expression: #"(c(xx))"#, expected: #"(c (x x))"#))

    XCTAssertTrue(successTest(expression: #"((\x.(\y.(x(\z.(xx)))))a)"#, expected: "λy.(a λz.(a a))"))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.(x(\z.(xx)))))a)b)"#, expected: "(a λz.(a a))"))
    XCTAssertTrue(successTest(expression: #"(((\x.(\y.(x((\z.(xx))c))))a)b)"#, expected: "(a (a a))"))
    
    XCTAssertTrue(successTest(expression: #"((\x.(xx))(\x.(xx)))"#, expected: "(λx.(x x) λx.(x x))"))
  }
}

private extension BetaConversionTests {
  func successTest(expression: String, expected: String) -> Bool {
    let parser = lambdaExpressionParser()
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map(betaConversion)
      .map { $0.0 }
      .map { $0.description == expected }
    if !didPass! {
      parse(parser, input: expression)
      .map { $0.0 }
      .map(betaConversion)
      .map { $0.0 }
      .map { print($0.description, expected) }
    }
    return didPass ?? false
  }
}
