//
//  main.swift
//  λcalculus
//
//  Created by Toni Kocjan on 04/12/2019.
//  Copyright © 2019 TSS. All rights reserved.
//

import Foundation

let parser = lambdaExpressionParser()
print(parse(parser, input: #"(\x.x)"#)!)
print(parse(parser, input: #"(xy)"#)!)
print(parse(parser, input: #"((\x.x)y)"#)!)
print(parse(parser, input: #"(\x.(\y.x))"#)!)
print(parse(parser, input: "(xx)")!)

print(parse(parser, input: #"\x.x"#)!)
print(parse(parser, input: #"\x.\y.x"#)!)
print(parse(parser, input: #"\x.xx"#)!)
print(parse(parser, input: #"\x.\y.x"#)!)
print(parse(parser, input: "xx")!)

print(parse(parser, input: #"((\f.\x.f(fx))(\y.y))"#)!)

let expression = #"""
(((\x.(\y.x))(\x.(\y.x)))(\x.(\y.y)))
"""#

print()

let dumpFileUrl = URL(string: "/Users/tonikocjan/dump.txt".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
let stream = FileOutputStream(fileWriter: try FileWriter(fileUrl: dumpFileUrl))
let tree = parse(parser, input: expression)!.0
stream.printLine(tree.treeLikeDescription)
print(tree)

print()

for i in λexpressionsGenerator(depth: 3) {
  print(i)
}
