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
(((\x.(\y.y))(\x.(\y.x)))(\x.(\y.y)))
"""#

print()

let dumpFileUrl = URL(string: "/Users/tonikocjan/dump.txt".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
let stream = FileOutputStream(fileWriter: try FileWriter(fileUrl: dumpFileUrl))
var tree = parse(parser, input: expression)!.0
stream.printLine(tree.treeLikeDescription)
print(tree)

print()

for i in λexpressionsGenerator(depth: 3) {
  print(i)
}

print()

//print(betaConversion(parse(parser, input: #"((\x.x)a)"#)!.0))
//print(betaConversion(parse(parser, input: #"(((\x.(\y.x))a)b)"#)!.0))
//print(betaConversion(parse(parser, input: #"(((\x.(\y.y))a)b)"#)!.0))
//print(betaConversion(parse(parser, input: #"(\x.(\y.x))"#)!.0))
//print(betaConversion(parse(parser, input: #"(((\x.(\y.y))(\x.(\y.x)))(\x.(\y.y)))"#)!.0))
//print(betaConversion(parse(parser, input: #"((\x.x)(\a.a))"#)!.0))
//print(betaConversion(parse(parser, input: #"(\x.(xx))"#)!.0))
//print(betaConversion(parse(parser, input: #"(xx)"#)!.0))
//print(betaConversion(parse(parser, input: #"((\x.(\y.(x(\z.(xx)))))a)"#)!.0))
//print(betaConversion(parse(parser, input: #"(((\x.(\y.(x(\z.(xx)))))a)b)"#)!.0))
//print(betaConversion(parse(parser, input: #"(((\x.(\y.(x((\z.(xx))c))))a)b)"#)!.0))
//print(betaConversion(parse(parser, input: #"((\x.(xx))(\x.(xx)))"#)!.0))
print(betaConversion(parse(parser, input: #"((\f.\x.(fx))(\f.\x.(fx)))"#)!.0))
print()


print(alphaConversion(parse(parser, input: #"(\x.(\x.x))"#)!.0))
print(alphaConversion(parse(parser, input: #"(\x.(\x.(\x.x)))"#)!.0))
print(alphaConversion(parse(parser, input: #"(\x.(\x.x))"#)!.0))
print(alphaConversion(parse(parser, input: #"\x.\y.x"#)!.0))
