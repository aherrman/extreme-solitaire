require 'rbtree'

# A queue that keeps its elements sorted based on the <=> operator.
# Requires the rbtree gem
class SortedQueue
  include Enumerable

  def initialize(ary=[])
    @queue = RBTree.new

    ary.each { |item| 
      @queue[item] = item
    }
  end

  def size
    @queue.size
  end

  def to_a
    @queue.to_a.inject([]) { |a, keyval|
      a << keyval[0]
    }
  end

  # Adds an item to the queue
  def add(item)
    @queue[item] = item
  end

  # Adds an item to the queue
  def <<(item)
    add(item)
  end

  # Removes an item from the queue
  def remove(item)
    @queue.delete(item)
  end

  # Removes the first element from the queue
  def shift
    shifted = @queue.shift

    return nil if shifted.nil?
    shifted[0]
  end

  # Checks if the item is contained in the queue
  def include?(item)
    @queue.include?(item)
  end

  def each
    @queue.each_key { |key|
      yield key
    }
    self
  end
end
