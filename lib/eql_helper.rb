# Defines helper methods for equality checking
#
# ===Example Usage
#   class TestClass
#     include EqlHelper
#
#     # ...
#
#     def eql?(other)
#       check_equal(other, [:@var1, :@var2])
#     end
#   end
module EqlHelper

  # Checks if two objects are equal by comparing the values of the variables in
  # the variables array on both objects
  def check_equal(other, variables)
    return true if equal?(other)
    return false unless other.is_a?(self.class)

    variables ||= []

    equal = true
    variables.each do |var|
      equal = check_var_equal(other, var)
      break unless equal
    end

    equal
  end

  # Use to check the equality of a variable in another object with the same
  # variable in this one.
  def check_var_equal(other, variable)
    mine = instance_variable_get(variable)
    theirs = other.instance_variable_get(variable)
    mine.eql? theirs
  end
end
