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

final class ConfigSim {
    static public let config = ConfigSim()
    
    private init() {
        inputFile = nil;
    }
    
    var inputFile: String?
    
    let version = "0.1"
    
    var debugOutput: Bool = false
    
    var currentDirectory: String = "."
    
    func processCommandLine() throws {
        guard CommandLine.argc > 1 else {
            throw ConfigError.tooFewArguments
        }
        
        for argument in CommandLine.arguments {
            switch argument {
            case "--dev":
                currentDirectory = "/Users/harryculpan/src/hacksim"
            case "--debug":
                debugOutput = true
            default:
                inputFile = argument
            }
        }
    }
    
    func outputUsage() {
        print("Usage: hacksim [--dev] [--debug] <hack file>")
        print("  --dev    Use pre-defined dev current directory, otherwise use .")
        print("  --debug  Enable debug output to console")
    }
}
