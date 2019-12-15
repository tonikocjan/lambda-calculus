//
//  ParserTests.swift
//  λcalculus
//
//  Created by Toni Kocjan on 05/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import XCTest

class ParserTests: XCTestCase {
  func testLambdaExpressionParser() {
    XCTAssertTrue(successLambdaTest(#"x"#, "x"))
    XCTAssertTrue(successLambdaTest(#"(\x.x)"#, "λx.x"))
    XCTAssertTrue(successLambdaTest(#"(xy)"#, "(x y)"))
    XCTAssertTrue(successLambdaTest(#"((\x.x)y)"#, "(λx.x y)"))
    XCTAssertTrue(successLambdaTest(#"(\x.(\y.x))"#, "λx.λy.x"))
    XCTAssertTrue(successLambdaTest(#"\x.x"#, "λx.x"))
    XCTAssertTrue(successLambdaTest( #"\x.\y.x"#, "λx.λy.x"))
    XCTAssertTrue(successLambdaTest(#"\x.xx"#, "(λx.x x)"))
    
    XCTAssertTrue(successLambdaTest(#"xx"#, "(x x)"))
    
    XCTAssertTrue(successLambdaTest("10", "10.0"))
    XCTAssertTrue(successLambdaTest(#"\x.10"#, "λx.10.0"))
    XCTAssertTrue(successLambdaTest(#"((+2)3)"#, "((+ 2.0) 3.0)"))
  }
  
  func testLanguageParser() {
    XCTAssertTrue(
      successLanguageTest(#"let x = \x.x"#,
                          [.binding(v: "x", e: .abstraction(variable: "x", expression: .variable(name: "x")))]))
    XCTAssertTrue(
      successLanguageTest("let x = \\x.x\nlet y = x",
                          [.binding(v: "x", e: .abstraction(variable: "x", expression: .variable(name: "x"))),
                           .binding(v: "y", e: .variable(name: "x"))]))
    XCTAssertTrue(
      successLanguageTest("x\ny",
                          [.execute(e: .variable(name: "x")),
                           .execute(e: .variable(name: "y"))]))
    XCTAssertTrue(
      successLanguageTest(#"  let    x  =\x.x"#,
                          [.binding(v: "x", e: .abstraction(variable: "x", expression: .variable(name: "x")))]))
    XCTAssertTrue(
      successLanguageTest(#"let x=\x.x"#,
                          [.binding(v: "x", e: .abstraction(variable: "x", expression: .variable(name: "x")))]))
    XCTAssertTrue(
      successLanguageTest("   x\n    y",
                          [.execute(e: .variable(name: "x")),
                           .execute(e: .variable(name: "y"))]))
  }
}

private extension ParserTests {
  func successLambdaTest(_ expression: String, _ expected: String) -> Bool {
    let parser = lambdaExpressionParser()
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map { $0.description == expected }
    if !didPass! {
      parse(parser, input: expression)
      .map { $0.0 }
      .map { print($0, expected) }
    }
    return didPass ?? false
  }
  
  func successLanguageTest(_ expression: String, _ expected: Program) -> Bool {
    let parser = programParser()
    let didPass = parse(parser, input: expression)
      .map { $0.0 }
      .map { $0 == expected }
    if !didPass! {
      parse(parser, input: expression)
      .map { $0.0 }
      .map { print($0, expected) }
    }
    return didPass ?? false
  }
}
