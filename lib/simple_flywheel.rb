# Defines methods to easily make a class into a Flywheel.
#
# This works for any class where each unique instance can be identified solely
# by the arguments passed to its construtor.
module SimpleFlywheel
  # Gets the object that matches the passed arguments.  If no such object exists
  # then it is created by passing its arguments to new, adding the new object
  # to the cache, and then returning it.
  #
  # ===Example
  #   class FlywheelTestClass
  #     attr_reader :value1, :value2
  #
  #     extend SimpleFlywheel
  #
  #     def initialize(val1, val2)
  #       @value1 = val1
  #       @value2 = val2
  #     end
  #   end
  #
  #   o1 = FlywheelTestClass.get(1, 3)
  #   o2 = FlywheelTestClass.get(5, 6)
  #   o3 = FlywheelTestClass.get(1, 3)  # returns same object as o1
  def get(*args)
    @flywheel_cach = {} if @flywheel_cach.nil?

    cached = @flywheel_cach[args]

    return cached unless cached.nil?

    cached = self.new(*args)
    @flywheel_cach[args] = cached

    cached
  end

  # Clears the flywheel cache.
  def clear_flywheel_cache
    @flywheel_cach = {}
  end
end
