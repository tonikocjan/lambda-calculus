//
//  FileReader.swift
//  Atheris
//
//  Created by Toni Kocjan on 30/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol FileReaderProtocol {
  init(fileUrl url: URL) throws
  func closeFile()
  func readByte() throws -> UInt8
  func readBytes(count: Int) -> Data
  func readChar() throws -> String
  func readLine() -> String?
  func readString(size: Int) -> String?
  func readLines() -> [String]
}

public class FileReader: FileReaderProtocol {
  private let fileHandle: FileHandle
  
  public required init(fileUrl url: URL) throws {
    self.fileHandle = try FileHandle(forReadingFrom: url)
  }
  
  public func closeFile() {
    self.fileHandle.closeFile()
  }
  
  public func readByte() throws -> UInt8 {
    guard let byte = [UInt8](fileHandle.readData(ofLength: 1)).first else { throw Error.fileEmpty }
    return byte
  }
  
  public func readBytes(count: Int) -> Data {
    return fileHandle.readData(ofLength: count)
  }
  
  public func readChar() throws -> String {
    let byte = try readByte()
    
    if byte >> 7 & 1 == 0 {
      return String(bytes: [byte], encoding: .utf8)!
    }
    
    if byte >> 6 & 1 == 0 && byte >> 5 == 0 {
      guard let char = String(bytes: [byte,
                                      try readByte()],
                              encoding: .utf8) else { throw Error.invalidFormat }
      return char
    }
    
    if byte >> 4 & 1 == 0 {
      guard let char = String(bytes: [byte,
                                      try readByte(),
                                      try readByte()],
                              encoding: .utf8) else { throw Error.invalidFormat }
      return char
    }
    
    guard let char = String(bytes: [byte,
                                    try readByte(),
                                    try readByte(),
                                    try readByte()],
                            encoding: .utf8)
      else { throw Error.invalidFormat }
    return char
  }
  
  public func readLine() -> String? {
    var line = ""
    do {
      var char = try readChar()
      while char != "\n" {
        line.append(char)
        char = try readChar()
      }
      return line
    } catch {
      return line.isEmpty ? nil : line
    }
  }
  
  public func readString(size: Int) -> String? {
    String(data: readBytes(count: size), encoding: .utf8)
  }
  
  public func readLines() -> [String] {
    var lines = [String]()
    while let line = readLine() {
      lines.append(line)
    }
    return lines
  }
}

public extension FileReader {
  enum Error: Swift.Error {
    case fileEmpty
    case invalidFormat
  }
}
