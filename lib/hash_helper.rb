# Defines helper methods for hash generation
#
# ===Example Usage
#   class TestClass
#     include HashHelper
#
#     # ...
#
#     def hash
#       generate_hash([:@var1, :@var2])
#     end
#   end
module HashHelper
  # Generates a hash value for the object based on a set of variables.
  def generate_hash(variables=nil)
    variables ||= []

    variables.inject(0) { |value, var|
      value ^ instance_variable_get(var).hash
    }
  end
end
