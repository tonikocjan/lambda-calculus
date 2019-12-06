//
//  ParserTests.swift
//  λcalculus
//
//  Created by Toni Kocjan on 05/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {
  func testParser() {
    XCTAssertTrue(successTest(expression: #"(\x.x)"#, expected: "λx.x"))
    XCTAssertTrue(successTest(expression: #"(xy)"#, expected: "(x y)"))
    XCTAssertTrue(successTest(expression: #"((\x.x)y)"#, expected: "(λx.x y)"))
    XCTAssertTrue(successTest(expression: #"(\x.(\y.x))"#, expected: "λx.λy.x"))
    XCTAssertTrue(successTest(expression: #"\x.x"#, expected: "λx.x"))
    XCTAssertTrue(successTest(expression: #"\x.\y.x"#, expected: "λx.λy.x"))
    XCTAssertTrue(successTest(expression: #"\x.xx"#, expected: "(λx.x x)"))
    XCTAssertTrue(successTest(expression: #"xx"#, expected: "(x x)"))
  }
}

private extension ParserTests {
  func successTest(expression: String, expected: String) -> Bool {
    let parser = lambdaExpressionParser()
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map { $0.description == expected }
    return didPass ?? false
  }
}
