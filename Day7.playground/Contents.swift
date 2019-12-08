// https://adventofcode.com/2019/day/7

import Foundation

typealias Program = [Int]

typealias Address = Int

enum ParameterMode: Int {
  case position = 0
  case immediate = 1

  func valueFrom(program: Program, address: Address) -> Int {
    switch self {
    case .position:
      return program[address]
    case .immediate:
      return address
    }
  }
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

protocol Instruction {
  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address
}

struct WriteInstruction: Instruction {
  let operation: (Int, Int) -> Int

  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address {
    let leftAddress = program[address + 1]
    let rightAddress = program[address + 2]
    let resultAddress = program[address + 3]

    let left = paramModes.first.valueFrom(program: program, address: leftAddress)
    let right = paramModes.second.valueFrom(program: program, address: rightAddress)
    let result = operation(left, right)

    program[resultAddress] = result

    return address + 4
  }
}

struct InputInstruction: Instruction {
  let input: Int

  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address {
    let inputAddress = program[address + 1]

    program[inputAddress] = input

    return address + 2
  }
}

struct OutputInstruction: Instruction {
  let operation: (Int) -> Void

  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address {
    let outputAddress = program[address + 1]
    let output = paramModes.first.valueFrom(program: program, address: outputAddress)

    operation(output)

    return address + 2
  }
}

struct JumpInstruction: Instruction {
  let operation: (Int) -> Bool

  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address {
    let valueAddress = program[address + 1]
    let destinationAddress = program[address + 2]

    let value = paramModes.first.valueFrom(program: program, address: valueAddress)
    let destination = paramModes.second.valueFrom(program: program, address: destinationAddress)

    if operation(value) {
      return destination
    }

    return address + 3
  }
}

struct HaltInstruction: Instruction {
  let operation: (Program) -> Address

  func execute(program: inout Program, address: Address, paramModes: ParameterModes) -> Address {
    return operation(program)
  }
}

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

func run(program: Program, inputQueue: Queue<Int>, outputQueue: Queue<Int>) {
  var memory = program
  var optcodeAddress = 0

  while optcodeAddress < memory.endIndex {
    let optcode = memory[optcodeAddress]
    let command = Command(optcode: optcode)

    let instruction: Instruction

    switch command {
    case .addition:
      instruction = WriteInstruction(operation: +)
    case .multiplication:
      instruction = WriteInstruction(operation: *)
    case .input:
      instruction = InputInstruction(input: inputQueue.removeFirst())
    case .output:
      instruction = OutputInstruction(operation: { outputQueue.append($0) })
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

    optcodeAddress = instruction.execute(
      program: &memory,
      address: optcodeAddress,
      paramModes: paramModes
    )
  }
}

extension Array {
  func chopped() -> (Element, [Element])? {
    guard let x = self.first else { return nil }
    return (x, Array(self.suffix(from: 1)))
  }

  func interleaved(_ element: Element) -> [[Element]] {
    guard let (head, rest) = self.chopped() else { return [[element]] }
    return [[element] + self] + rest.interleaved(element).map { [head] + $0 }
  }

  var permutations: [[Element]] {
    guard let (head, rest) = self.chopped() else { return [[]] }
    return rest.permutations.flatMap { $0.interleaved(head) }
  }
}

// Unbounded, blocking queue
class Queue<Element> {
  let dispatchQueue = DispatchQueue(label: "Queue")
  let filledSemaphore = DispatchSemaphore(value: 0)

  var buffer: [Element] = []

  init(_ element: Element) {
    self.append(element)
  }

  func append(_ element: Element) {
    self.dispatchQueue.sync { buffer.append(element) }

    self.filledSemaphore.signal()
  }

  func removeFirst() -> Element {
    self.filledSemaphore.wait()

    var result: Element?

    self.dispatchQueue.sync { result = self.buffer.removeFirst() }

    return result!
  }
}

typealias Task = (Int) -> Void

typealias TaskRunner = (Int, Task) -> Void

func transformPhaseSettingsIntoSignal(
  phaseSettings: [Int],
  program: Program,
  taskRunner: TaskRunner
) -> Int {
  let queues = phaseSettings.map { phaseSetting in Queue<Int>(phaseSetting) }

  queues.first!.append(0)

  taskRunner(queues.count) { index in
    let inputQueue = queues[index]
    let outputQueue = queues[(index + 1) % phaseSettings.count]

    run(program: program, inputQueue: inputQueue, outputQueue: outputQueue)
  }

  return queues.first!.removeFirst()
}

func solve(phases: [Int], program: Program, taskRunner: TaskRunner) -> Int {
  return phases
    .permutations
    .map { phaseSettings in
      transformPhaseSettingsIntoSignal(
        phaseSettings: phaseSettings,
        program: program,
        taskRunner: taskRunner
      )
    }
    .max()!
}

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
let intcode = input
  .trimmingCharacters(in: .newlines)
  .split(separator: ",")
  .compactMap { Int($0) }

let answer1 = solve(phases: Array(0...4), program: intcode) { iterations, task in
  (0..<iterations).forEach(task)
}

print(answer1)

let answer2 = solve(phases: Array(5...9), program: intcode) { iterations, task in
  DispatchQueue.concurrentPerform(iterations: iterations, execute: task)
}

print(answer2)
