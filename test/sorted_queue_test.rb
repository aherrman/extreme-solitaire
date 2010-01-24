$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sorted_queue'

class SortedQueueTest < Test::Unit::TestCase
  def test_create_empty_queue
    queue = SortedQueue.new
    assert_equal 0, queue.size
  end

  def test_create_queue_from_array
    queue = SortedQueue.new [1, 5, 3, 4, 2]

    assert_equal 5, queue.size
    assert_equal 1, queue.shift
    assert_equal 2, queue.shift
    assert_equal 3, queue.shift
    assert_equal 4, queue.shift
    assert_equal 5, queue.shift
  end

  def test_size
    queue = SortedQueue.new
    queue << 1
    queue << 5

    assert_equal 2, queue.size
  end

  def test_add_and_shift
    queue = SortedQueue.new

    queue << 5
    queue.add 2

    assert_equal 2, queue.shift
    assert_equal 5, queue.shift
  end

  def test_remove
    queue = SortedQueue.new [1, 3, 5, 7]

    queue.remove 3

    assert_equal 1, queue.shift
    assert_equal 5, queue.shift
    assert_equal 7, queue.shift
    assert queue.shift.nil?
  end

  def test_to_a
    queue = SortedQueue.new
    queue << 1
    queue << 6
    queue << 3

    assert_equal [1, 3, 6], queue.to_a
  end

  def test_include
    queue = SortedQueue.new [1, 2, 3, 4, 5]

    assert queue.include?(3)
    assert ! queue.include?(9)
  end

  def test_each
    queue = SortedQueue.new [1, 2, 3, 4, 5]

    a = []
    queue.each { |val|
      a << val
    }

    assert_equal [1, 2, 3, 4, 5], a
  end
end
