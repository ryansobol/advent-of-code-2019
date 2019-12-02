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
  var optcodePtr = 0
  var optcode = memory[optcodePtr]

  while optcode != 99 {
    let leftPtr = memory[optcodePtr + 1]
    let rightPtr = memory[optcodePtr + 2]
    let resultPtr = memory[optcodePtr + 3]

    let left = memory[leftPtr]
    let right = memory[rightPtr]
    let result = optcode == 1 ? left + right : left * right

    memory[resultPtr] = result

    optcodePtr += 4
    optcode = memory[optcodePtr]
  }

  return memory[0]
}

print(runProgram(intcode))

func searchInputs(_ target: Int) -> Int {
  for noun in 0...99 {
    for verb in 0...99 {
      intcode[1] = noun
      intcode[2] = verb

      let result = runProgram(intcode)

      if result == target {
        return 100 * noun + verb
      }
    }
  }

  return -1
}

print(searchInputs(19690720))
