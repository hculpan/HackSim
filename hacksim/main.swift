//
//  main.swift
//  hacksim
//
//  Created by Harry Culpan on 6/13/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Foundation

let configSim = ConfigSim.config

print("HackSim v.\(configSim.version)")

do {
    try configSim.processCommandLine()
    
    let fileManager = FileManager.default
    fileManager.changeCurrentDirectoryPath(configSim.currentDirectory)
    
    if fileManager.fileExists(atPath: configSim.inputFile!) {
        let cpuSim = CpuSim()
        print("Loading ROM file \(configSim.inputFile!)")
        do {
            let contents = try String(contentsOfFile: configSim.inputFile!)
            let lines = contents.components(separatedBy: "\n")
            var cnt = 0
            for line in lines {
                if !line.isEmpty {
                    cpuSim.setRomValue(address: UInt16(cnt), value: UInt16(line, radix: 2)!)
                    cnt += 1
                }
            }
            print("ROM loaded")
            try cpuSim.execute()
        } catch (CpuError.cpuInvalidInstruction) {
            print("Cpu halt: Invalid instruction!")
        } catch {
            throw ConfigError.hackFileFailedLoad
        }
    } else {
        throw ConfigError.hackFileNotFound
    }
} catch (ConfigError.hackFileFailedLoad) {
    print("Must specify hack program file")
    configSim.outputUsage()
} catch (ConfigError.tooFewArguments) {
    print("Must specify hack program file")
    configSim.outputUsage()
} catch (ConfigError.hackFileNotFound) {
    print("Specified hack file (\(configSim.inputFile!)) not found")
    configSim.outputUsage()
}

