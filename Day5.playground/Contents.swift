import Foundation

enum Command: Int {
  case addition = 1
  case multiplication = 2
  case input = 3
  case output = 4
  case jumpIfTrue = 5
  case jumpIfFalse = 6
  case lessThan = 7
  case equalTo = 8
  case halt = 99

  init(optcode: Int) {
    self.init(rawValue: optcode % 100)!
  }
}

enum ParameterMode: Int {
  case position = 0
  case immediate = 1
}

struct ParameterModes {
  let first: ParameterMode
  let second: ParameterMode
  let third: ParameterMode  // Defined by the problem, but not used

  init(optcode: Int) {
    self.first = ParameterMode(rawValue: optcode / 100 % 10)!
    self.second = ParameterMode(rawValue: optcode / 1000 % 10)!
    self.third = ParameterMode(rawValue: optcode / 10000 % 10)!
  }
}

typealias Program = [Int]

typealias Pointer = Int

protocol Instruction {
  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer
}

struct WriteInstruction: Instruction {
  let operation: (Int, Int) -> Int

  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer {
    let leftPtr = program[pointer + 1]
    let rightPtr = program[pointer + 2]
    let resultPtr = program[pointer + 3]

    let left: Int
    let right: Int

    switch paramModes.first {
    case .position:
      left = program[leftPtr]
    case .immediate:
      left = leftPtr
    }

    switch paramModes.second {
    case .position:
      right = program[rightPtr]
    case .immediate:
      right = rightPtr
    }

    let result = operation(left, right)

    program[resultPtr] = result

    return pointer + 4
  }
}

struct InputInstruction: Instruction {
  let input: Int

  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer {
    let inputPtr = program[pointer + 1]

    program[inputPtr] = input

    return pointer + 2
  }
}

struct OutputInstruction: Instruction {
  let operation: (Int) -> Void

  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer {
    let outputPtr = program[pointer + 1]

    let output: Int

    switch paramModes.first {
    case .position:
      output = program[outputPtr]
    case .immediate:
      output = outputPtr
    }

    operation(output)

    return pointer + 2
  }
}

struct JumpInstruction: Instruction {
  let operation: (Int) -> Bool

  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer {
    let valuePtr = program[pointer + 1]
    let destinationPtr = program[pointer + 2]

    let value: Int
    let destination: Int

    switch paramModes.first {
    case .position:
      value = program[valuePtr]
    case .immediate:
      value = valuePtr
    }

    switch paramModes.second {
    case .position:
      destination = program[destinationPtr]
    case .immediate:
      destination = destinationPtr
    }

    if operation(value) {
      return destination
    }

    return pointer + 3
  }
}

struct HaltInstruction: Instruction {
  let operation: (Program) -> Pointer

  func execute(program: inout Program, pointer: Pointer, paramModes: ParameterModes) -> Pointer {
    return operation(program)
  }
}

func runProgram(program: Program, input: Int) {
  var memory = program
  var optcodePtr = 0

  while optcodePtr < memory.endIndex {
    let optcode = memory[optcodePtr]
    let command = Command(optcode: optcode)

    let instruction: Instruction

    switch command {
    case .addition:
      instruction = WriteInstruction(operation: +)
    case .multiplication:
      instruction = WriteInstruction(operation: *)
    case .input:
      instruction = InputInstruction(input: input)
    case .output:
      instruction = OutputInstruction(operation: { print($0) })
    case .jumpIfTrue:
      instruction = JumpInstruction(operation: { $0 != 0 })
    case .jumpIfFalse:
      instruction = JumpInstruction(operation: { $0 == 0 })
    case .lessThan:
      instruction = WriteInstruction(operation: { $0 < $1 ? 1 : 0 })
    case .equalTo:
      instruction = WriteInstruction(operation: { $0 == $1 ? 1 : 0 })
    case .halt:
      instruction = HaltInstruction(operation: { $0.endIndex })
    }

    let paramModes = ParameterModes(optcode: optcode)

    optcodePtr = instruction.execute(
      program: &memory,
      pointer: optcodePtr,
      paramModes: paramModes
    )
  }
}

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
let intcode = input
  .trimmingCharacters(in: .newlines)
  .split(separator: ",")
  .compactMap { Int($0) }

print("Answer 1:")
runProgram(program: intcode, input: 1)

print("Answer 2:")
runProgram(program: intcode, input: 5)

