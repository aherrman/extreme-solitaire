# Checks if 2 Enumerables have the same contents regardless of ordering
def are_contents_the_same?(a1, a2)
  begin
    return false if (a1.size != a2.size)
  rescue NoMethodError
    # size isn't defined so we'll skip this optimization
  end
  return true if (a1.equal?(a2))

  hash = {}
  a1.each { |o|
    hash[o] = 0 if hash[o].nil?
    hash[o] += 1
  }

  same = true
  a2.each { |o|
    # a2 has something that isn't in a1 OR is in a1 less times than in a2
    if (hash[o].nil?) || (hash[o] == 0)
      same = false
      break
    end

    hash[o] -= 1
  }

  return false unless same

  ! (hash.values.any? { |o| o > 0 })
end