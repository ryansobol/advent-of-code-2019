func transformPasswordToDigits(password: Int) -> [Int] {
  return String(password).compactMap { character in character.wholeNumberValue }
}

func hasIncreasingDigits(digits: [Int]) -> Bool {
  let lastIndex = digits.endIndex - 1

  return (0..<lastIndex)
    .filter { index in digits[index] <= digits[index + 1] }
    .count == lastIndex
}

func hasMatchingTwoDigits(digits: [Int]) -> Bool {
  let lastIndex = digits.endIndex - 1

  return (0..<lastIndex)
    .filter { index in digits[index] == digits[index + 1] }
    .count > 0
}

func hasGroupingOfTwoDigits(digits: [Int]) -> Bool {
  return digits
    .reduce(into: [:]) { accum, digit in accum[digit, default: 0] += 1 }
    .values
    .contains(2)
}

let passwordRange = 234208...765869

let increasingDigits = passwordRange
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
