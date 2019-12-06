//
//  FileOutputStream.swift
//  Atheris
//
//  Created by Toni Kocjan on 07/10/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class FileOutputStream: OutputStream {
  public let fileWriter: FileWriterProtocol
  
  public init(fileWriter: FileWriterProtocol) {
    self.fileWriter = fileWriter
  }
  
  public func print(_ string: String) {
    fileWriter.writeString(string)
  }
  
  public func printLine(_ string: String) {
    fileWriter.writeLine(string)
  }
}
