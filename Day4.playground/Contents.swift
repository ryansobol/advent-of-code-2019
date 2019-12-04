func transformPasswordToDigits(password: Int) -> [Int] {
  return String(password).compactMap { $0.wholeNumberValue }
}

func hasIncreasingDigits(digits: [Int]) -> Bool {
  return (0...4).filter { digits[$0] <= digits[$0 + 1] }.count == 5
}

func hasMatchingTwoDigits(digits: [Int]) -> Bool {
  return (0...4).filter { digits[$0] == digits[$0 + 1] }.count > 0
}

func hasGroupingOfTwoDigits(digits: [Int]) -> Bool {
  return digits.reduce(into: [:]) { accum, digit in
    accum[digit, default: 0] += 1
  }.values.contains(2)
}

let passwordRange = 234208...765869

let increasingDigits = passwordRange
  .lazy
  .map(transformPasswordToDigits)
  .filter(hasIncreasingDigits)

let answer1 = increasingDigits
  .filter(hasMatchingTwoDigits)
  .count

print(answer1)

let answer2 = increasingDigits
  .filter(hasGroupingOfTwoDigits)
  .count

print(answer2)
