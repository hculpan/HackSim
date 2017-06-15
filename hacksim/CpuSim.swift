//
//  CpuSim.swift
//  HackSim
//
//  Created by Harry Culpan on 6/13/17.
//  Copyright © 2017 Harry Culpan. All rights reserved.
//

import Foundation

enum CpuError: Error {
    case cpuInvalidInstruction
    case cpuInvalidComputation
}

class CpuSim {
    let configSim = ConfigSim.config
    
    var rom: [UInt16] = Array(repeating: 0, count: 32768)
    var ram: [Int16] = Array(repeating: 0, count: 32768)
    
    var a: Int16 = 0
    var d: Int16 = 0
    var ip: UInt16 = 0
    var m: Int16 {
        get {
            return ram[Int(a)]
        }
        set {
            ram[Int(a)] = newValue
        }
    }
    
    init() {
        
    }
    
    func cprint(_ text: String) {
        if configSim.debugOutput {
            print(text)
        }
    }
    
    func execute() throws {
        while (true) {
            let code: UInt16 = UInt16(getRomValue(address: ip))
            cprint("code = \(String(code, radix:2))")
            if code == 0xA000 { // R-instruction, 1010000000000000
                cprint("Hard stop instruction")
                break
            } else if code & 0xE000 > 0 { // C-instruction, 111xxxxxxxxxxxxx
                ip = try processCInstruction(code: code)
            } else if code & 0x8000 == 0 { // A-instruction, 0xxxxxxxxxxxxxxx
                a = Int16(code & 0x7FFF)
                ip = ip &+ 1
                cprint("A instruction: A = \(a)")
            } else {
                cprint("Unrecognized instruction")
            }
            
            if ip > 32767 {
                break
            }
        }
    }
    
    func evaluateComputation(code: UInt16) throws -> Int16 {
        let compIndex = (code >> 6) & 0x007F
        var calcValue: Int16
        
        switch compIndex {
        case   0: calcValue = self.d & self.a
        case   2: calcValue = self.d &+ self.a
        case   7: calcValue = self.a &- self.d
        case  12: calcValue = self.d
        case  13: calcValue = ~self.d
        case  14: calcValue = self.d &- 1
        case  15: calcValue = ~self.d &+ 1
        case  19: calcValue = self.d &- self.a
        case  21: calcValue = self.d | self.a
        case  31: calcValue = self.d &+ 1
        case  41: calcValue = ~self.a
        case  42: calcValue = 0
        case  48: calcValue = self.a
        case  50: calcValue = self.a &- 1
        case  51: calcValue = ~self.a &+ 1
        case  55: calcValue = self.a &+ 1
        case  58: calcValue = -1
        case  63: calcValue = 1
        case  64: calcValue = self.d & self.m
        case  66: calcValue = self.d &+ self.m
        case  71: calcValue = self.m &- self.d
        case  83: calcValue = self.d &- self.m
        case  85: calcValue = self.d | self.m
        case 112: calcValue = self.m
        case 113: calcValue = ~self.m
        case 114: calcValue = self.m &- 1
        case 115: calcValue = ~self.m &+ 1
        case 119: calcValue = self.m &+ 1
        default:
            throw CpuError.cpuInvalidComputation
        }

        return calcValue
    }
    
    func processCInstruction(code: UInt16) throws -> UInt16 {
        let calcValue: Int16 = try evaluateComputation(code: code)
        var finalIp: UInt16 = self.ip + 1

        let destIndex = (code >> 3) & 0x0007
        switch destIndex {
        case 0:
            break
        case 1:
            self.m = calcValue
        case 2:
            self.d = calcValue
        case 3:
            self.d = calcValue
            self.m = calcValue
        case 4:
            self.a = calcValue
        case 5:
            self.a = calcValue
            self.m = calcValue
        case 6:
            self.a = calcValue
            self.d = calcValue
        case 7:
            self.m = calcValue
            self.a = calcValue
            self.d = calcValue
        default:
            throw CpuError.cpuInvalidInstruction
        }
        
        let jumpDest = code & 0x0007
        switch jumpDest {
        case 0:
            break;
        case 1:
            finalIp = (calcValue > 0 ? UInt16(self.a) : finalIp)
        case 2:
            finalIp = (calcValue == 0 ? UInt16(self.a) : finalIp)
        case 3:
            finalIp = (calcValue >= 0 ? UInt16(self.a) : finalIp)
        case 4:
            finalIp = (calcValue < 0 ? UInt16(self.a) : finalIp)
        case 5:
            finalIp = (calcValue != 0 ? UInt16(self.a) : finalIp)
        case 6:
            finalIp = (calcValue <= 0 ? UInt16(self.a) : finalIp)
        case 7:
            finalIp = UInt16(self.a)
        default:
            throw CpuError.cpuInvalidInstruction
        }
        
        cprint("C instruction: a=\(self.a) : d=\(self.d) : m=\(self.m)")
        return finalIp
    }
    
    func reset() {
        ip = 0
    }
    
    func setRomValue(address: UInt16, value: UInt16) {
        rom[Int(address)] = value
    }
    
    func getRomValue(address: UInt16) -> UInt16 {
        return rom[Int(address)]
    }
    
    func setRamValue(address: UInt16, value: Int16) {
        ram[Int(address)] = value
    }
    
    func getRamValue(address: UInt16) -> Int16 {
        return ram[Int(address)]
    }
}
