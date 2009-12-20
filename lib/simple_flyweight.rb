# Defines methods to easily make a class into a Flyweight.
#
# This works for any class where each unique instance can be identified solely
# by the arguments passed to its construtor.
module SimpleFlyweight
  # Gets the object that matches the passed arguments.  If no such object exists
  # then it is created by passing its arguments to new, adding the new object
  # to the cache, and then returning it.
  #
  # ===Example
  #   class FlyweightTestClass
  #     attr_reader :value1, :value2
  #
  #     extend SimpleFlyweight
  #
  #     def initialize(val1, val2)
  #       @value1 = val1
  #       @value2 = val2
  #     end
  #   end
  #
  #   o1 = FlyweightTestClass.get(1, 3)
  #   o2 = FlyweightTestClass.get(5, 6)
  #   o3 = FlyweightTestClass.get(1, 3)  # returns same object as o1
  def get(*args)
    @flyweight_cach = {} if @flyweight_cach.nil?

    cached = @flyweight_cach[args]

    return cached unless cached.nil?

    cached = self.new(*args)
    @flyweight_cach[args] = cached

    cached
  end

  # Clears the flyweight cache.
  def clear_flyweight_cache
    @flyweight_cach = {}
  end
end
