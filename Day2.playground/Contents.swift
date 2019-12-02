import Foundation

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let input = try! String(contentsOf: url!)
var intcode = input
  .trimmingCharacters(in: .newlines)
  .split(separator: ",")
  .map { Int($0)! }

intcode[1] = 12
intcode[2] = 2

func runProgram(_ intcode: [Int]) -> Int {
  var memory = intcode

  for optcodePtr in stride(from: 0, to: memory.count - 1, by: 4) {
    let leftPtr = memory[optcodePtr + 1]
    let rightPtr = memory[optcodePtr + 2]
    let resultPtr = memory[optcodePtr + 3]

    let optcode = memory[optcodePtr]
    let left = memory[leftPtr]
    let right = memory[rightPtr]
    let operation: (Int, Int) -> Int

    if optcode == 1 {
      operation = (+)
    }
    else if optcode == 2 {
      operation = (*)
    }
    else if optcode == 99 {
      break
    }
    else {
      preconditionFailure("Invalid optcode: \(optcode)")
    }

    memory[resultPtr] = operation(left, right)
  }

  return memory[0]
}

print(runProgram(intcode))

func checkForMatch(_ target: Int, _ memory: [Int], _ result: Int) {
  DispatchQueue.global().async {
    if runProgram(memory) == target {
      print(result)
    }
  }
}

let target = 19690720

for noun in 0...99 {
  for verb in 0...99 {
    intcode[1] = noun
    intcode[2] = verb

    let result = 100 * noun + verb

    checkForMatch(target, intcode, result)
  }
}
