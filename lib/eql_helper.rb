# Defines helper methods for equality checking
#
# ===Example Usage
#   class TestClass
#     include EqlHelper
#
#     # ...
#
#     def eql?(other)
#       check_equal(self, other, [:@var1, :@var2])
#     end
#   end
module EqlHelper

  # Checks if two objects are equal by comparing the values of the variables in
  # the variables array on both objects
  def check_equal(obj1, obj2, variables)
    return true if obj1.equal?(obj2)
    return false unless obj2.is_a?(obj1.class)

    variables ||= []

    equal = true
    variables.each do |var|
      equal = check_var_equal(obj1, obj2, var)
      break unless equal
    end

    equal
  end

  # Use to check the equality of a variable in two objects.
  def check_var_equal(obj1, obj2, variable)
    v1 = obj1.instance_variable_get(variable)
    v2 = obj2.instance_variable_get(variable)
    v1.eql? v2
  end
end
