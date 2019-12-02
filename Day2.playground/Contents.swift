import Foundation

let url = Bundle.main.url(forResource: "input", withExtension: "txt")
let contents = try! String(contentsOf: url!)
var input = contents
  .trimmingCharacters(in: .newlines)
  .split(separator: ",")
  .map { Int($0)! }

input[1] = 12
input[2] = 2

func runProgram(_ input: [Int]) -> Int {
  var integers = input
  var optcodeIdx = 0
  var optcode = integers[optcodeIdx]

  while optcode != 99 {
    let leftIdx = integers[optcodeIdx + 1]
    let rightIdx = integers[optcodeIdx + 2]
    let resultIdx = integers[optcodeIdx + 3]

    let left = integers[leftIdx]
    let right = integers[rightIdx]
    let result = optcode == 1 ? left + right : left * right

    integers[resultIdx] = result

    optcodeIdx += 4
    optcode = integers[optcodeIdx]
  }

  return integers[0]
}

print(runProgram(input))
