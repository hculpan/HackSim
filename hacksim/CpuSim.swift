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
}

class Memory {
    var readOnly: Bool = false
    
    let memSize: UInt16 = 32768
    
    var memory: [UInt16] = Array(repeating: 0, count: 32767)
    
    init(readOnly: Bool = false) {
        self.readOnly = readOnly
    }
    
    fileprivate func setValue(address: UInt16, value: UInt16) {
        memory[Int(address)] = value
    }
    
    subscript(index: UInt16) -> UInt16 {
        get {
            return memory[Int(index % memSize)]
        }
        set {
            if !readOnly {
                memory[Int(index % memSize)] = newValue
            }
        }
    }
}

class CpuSim {
    let rom = Memory(readOnly: true)
    let ram = Memory()
    
    var a: UInt16 = 0
    var m: UInt16 = 0
    var d: UInt16 = 0
    var ip: UInt16 = 0
    
    init() {
        
    }
    
    func execute() throws {
        while (true) {
            let code: UInt16 = getRomValue(address: ip)
            print("code = \(String(code, radix:2))")
            if code == 0xA000 { // R-instruction, 1010000000000000
                print("Hard stop instruction")
                break
            } else if code & 0xE000 > 0 { // C-instruction, 111xxxxxxxxxxxxx
                ip = try processCInstruction(code: code)
            } else if code & 0x8000 == 0 { // A-instruction, 0xxxxxxxxxxxxxxx
                a = code & 0x7FFF
                ip += 1
                print("A instruction: A = \(a)")
            } else {
                print("Unrecognized instruction")
            }
            
            if ip > 32767 {
                break
            }
        }
    }
    
    func processCInstruction(code: UInt16) throws -> UInt16 {
        let compIndex = (code >> 6) & 0x007F
        var calcValue: UInt16
        switch compIndex {
        case 0: calcValue = self.d + self.a
        case 48: calcValue = a
        default:
            calcValue = 0
           // throw CpuError.cpuInvalidInstruction
        }
        print("C instruction, comp = \(compIndex), result = \(calcValue), a=\(self.a) : d=\(self.d)")
        return ip + 1
    }
    
    func reset() {
        ip = 0
    }
    
    func setRomValue(address: UInt16, value: UInt16) {
        rom.setValue(address: address, value: value)
    }
    
    func getRomValue(address: UInt16) -> UInt16 {
        return rom[address]
    }
    
    func setRamValue(address: UInt16, value: UInt16) {
        ram.setValue(address: address, value: value)
    }
    
    func getRamValue(address: UInt16) -> UInt16 {
        return ram[address]
    }
}
