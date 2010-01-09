# Proxies any object but doesn't allow any mutating method (methods ending in
# !) from being called.
class ImmutableProxy
  def initialize(target)
    @target = target
  end

  def method_missing(name, *args, &block)
    raise "Mutable methods not allowed" unless allowed?(name)
    @target.send(name, *args, &block)
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

  def class
    @target.class
  end

  def is_a?(c)
    @target.is_a?(c)
  end

private
  def allowed?(name)
    ! name.to_s.end_with?('!') || !@target.respond_to?(name)
  end
end
