# Proxies any object but doesn't allow any mutating method (methods ending in
# !) from being called.
class ImmutableProxy
  def initialize(target)
    @target = target
  end

  # Use this to call any built-in object methods that are masked by
  # ImmutableProxy's built-in object methods.
  def send_to_target(name, *args, &block)
    raise "Mutable methods not allowed" unless allowed?(name)
    @target.__send__(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    ret = send_to_target(name, *args, &block)

    # Some of the methods we use return a new object of the same type as the
    # original target class.  We need to wrap those in an ImmutableProxy as
    # well to make sure the user can't "cheat" by duplicating the target and
    # then modifying it.
    if ret.is_a?(@target.class)
      ImmutableProxy.new ret
    else
      ret
    end
  end

  def respond_to?(name, include_private=false)
    return false unless allowed?(name)
    @target.respond_to?(name, include_private)
  end

  def eql?(o)
    @target.eql?(o)
  end

  def ==(o)
    @target == o
  end

  def dup
    ImmutableProxy.new @target
  end

  def hash
    @target.hash
  end

  def is_a?(c)
    @target.is_a?(c)
  end

  def nil?
    @target.nil?
  end
private
  def allowed?(name)
    ! name.to_s.end_with?('!') || !@target.respond_to?(name)
  end
end
