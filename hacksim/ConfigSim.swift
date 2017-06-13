//
//  ConfigSim.swift
//  HackSim
//
//  Created by Harry Culpan on 6/12/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Foundation

enum ConfigError: Error {
    case tooFewArguments
    case invalidArguments
    case hackFileNotFound
    case hackFileFailedLoad
}

class ConfigSim {
    init() {
        inputFile = nil;
    }
    
    var inputFile: String?
    
    let version = "0.1"
    
    func processCommandLine() throws {
        guard CommandLine.argc > 1 else {
            throw ConfigError.tooFewArguments
        }
        
        inputFile = CommandLine.arguments[1]
    }
}
