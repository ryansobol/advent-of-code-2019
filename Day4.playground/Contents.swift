let passwordRange = 234208...765869

let increasingDigits = passwordRange
    .lazy
    .map { (password: Int) in String(password).compactMap { $0.wholeNumberValue } }
    .filter { (digits: [Int]) in (0...4).filter { digits[$0] <= digits[$0 + 1] }.count == 5 }

let answer1 = increasingDigits
    .filter { (digits: [Int]) in (0...4).filter { digits[$0] == digits[$0 + 1] }.count > 0 }
    .count

print(answer1)

let answer2 = increasingDigits
    .filter { (digits: [Int]) in digits.reduce(into: [:]) { $0[$1, default: 0] += 1 }.values.contains(2) }
    .count

print(answer2)
