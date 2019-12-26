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

print("---------")

var program = #"""
let x = \f.\x.(f(fx))
let y = \e.\r.(e(e(er)))
let z = \m.\n.(nm)
z
((zx)y)
"""#

// Either<Left, Right>
program = #"""
let L = \f.\g.\x.\y.(fx)
let R = \f.\g.\x.\y.(gy)

let Q = \a.((+a)8)
let Y = \a.((+a)100)

let p = ((((LQ)Y)2)5)
let l = ((((RQ)Y)2)5)
p
l
"""#

program = #"""
let T = \e.\m.\g.((ge)m)
let F = \h.(h(\a.\b.a))
let S = \i.(i(\c.\d.d))

let L = \f.\q.\x.\y.(fx)
let R = \l.\z.\j.\k.(zk)

let N = \f.\x.x
let C = \w.\t.((Tw)t)

let p = ((C1)((C2)((C3)N)))
(Fp)
(F(Sp))
(F(S(Sp)))
(S(S(Sp)))
"""#

// let f = (\h.\n.((((=n)1)1)(h((-n)1))))

print(".....")
// (f((-n)1))))

program = #"""
let f = \h.\n.((((=1)n)1)(h1))
((\x.(xx))(\x.(f(xx))))
"""#

program = #"""
let f = \n.((((=1)n)1)(f1))
(f1)
"""#

parse(programParser(), input: program)
  .map { $0.0 }
  .map(interpret)
  .map { print($0) } ?? print("error")
