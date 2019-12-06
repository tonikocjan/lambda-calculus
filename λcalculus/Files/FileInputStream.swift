//
//  FileInputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 06/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class FileInputStream: InputStream {
  public let fileReader: FileReaderProtocol
  
  public init(fileReader: FileReaderProtocol) {
    self.fileReader = fileReader
  }
  
  public func next() throws -> String {
    return try fileReader.readChar()
  }
}
