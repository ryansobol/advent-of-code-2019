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
  let third: ParameterMode

  init(optcode: Int) {
    self.first = ParameterMode(rawValue: optcode / 100 % 10)!
    self.second = ParameterMode(rawValue: optcode / 1000 % 10)!
    self.third = ParameterMode(rawValue: optcode / 10000 % 10)!
  }
}

typealias Pointer = Int

typealias Memory = [Int]

protocol Instruction {
  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer
}

struct BinaryWrite: Instruction {
  let operation: (Int, Int) -> Int

  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer {
    let leftPtr = memory[pointer + 1]
    let rightPtr = memory[pointer + 2]
    let resultPtr = memory[pointer + 3]

    let left: Int
    let right: Int

    switch paramModes.first {
    case .position:
      left = memory[leftPtr]
    case .immediate:
      left = leftPtr
    }

    switch paramModes.second {
    case .position:
      right = memory[rightPtr]
    case .immediate:
      right = rightPtr
    }

    let result = operation(left, right)

    memory[resultPtr] = result

    return pointer + 4
  }
}

struct Input: Instruction {
  let input: Int

  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer {
    let inputPtr = memory[pointer + 1]

    memory[inputPtr] = input

    return pointer + 2
  }
}

struct Output: Instruction {
  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer {
    let outputPtr = memory[pointer + 1]

    let output: Int

    switch paramModes.first {
    case .position:
      output = memory[outputPtr]
    case .immediate:
      output = outputPtr
    }

    print(output)

    return pointer + 2
  }
}

struct UnaryJump: Instruction {
  let operation: (Int) -> Bool

  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer {
    let valuePtr = memory[pointer + 1]
    let destinationPtr = memory[pointer + 2]

    let value: Int
    let destination: Int

    switch paramModes.first {
    case .position:
      value = memory[valuePtr]
    case .immediate:
      value = valuePtr
    }

    switch paramModes.second {
    case .position:
      destination = memory[destinationPtr]
    case .immediate:
      destination = destinationPtr
    }

    if operation(value) {
      return destination
    }

    return pointer + 3
  }
}

struct Halt: Instruction {
  func execute(pointer: Pointer, memory: inout Memory, paramModes: ParameterModes) -> Pointer {
    return memory.endIndex
  }
}

func runProgram(_ intcode: [Int], _ input: Int) {
  var memory = intcode
  var optcodePtr = 0

  while optcodePtr < memory.endIndex {
    let optcode = memory[optcodePtr]
    let command = Command(optcode: optcode)

    let instruction: Instruction

    switch command {
    case .addition:
      instruction = BinaryWrite(operation: +)
    case .multiplication:
      instruction = BinaryWrite(operation: *)
    case .input:
      instruction = Input(input: input)
    case .output:
      instruction = Output()
    case .jumpIfTrue:
      instruction = UnaryJump(operation: { $0 != 0 })
    case .jumpIfFalse:
      instruction = UnaryJump(operation: { $0 == 0 })
    case .lessThan:
      instruction = BinaryWrite(operation: { $0 < $1 ? 1 : 0 })
    case .equalTo:
      instruction = BinaryWrite(operation: { $0 == $1 ? 1 : 0 })
    case .halt:
      instruction = Halt()
    }

    let paramModes = ParameterModes(optcode: optcode)

    optcodePtr = instruction.execute(
      pointer: optcodePtr,
      memory: &memory,
      paramModes: paramModes
    )
  }
}

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
var intcode = input
  .trimmingCharacters(in: .newlines)
  .split(separator: ",")
  .compactMap { Int($0) }

runProgram(intcode, 5)

