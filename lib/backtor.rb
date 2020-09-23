require 'concurrent-ruby'
require 'concurrent-edge'

class Backtor
  def self.new_id
    @last_id ||= 0
    @last_id += 1
    @last_id
  end

  def initialize(*args, name: nil, __backtor_special_main: false, &block)
    raise ArgumentError, 'must be called with a block' if block.nil?
    raise TypeError, "no implicit conversion of #{name.class} into String" \
      unless name.nil? || name.is_a?(String)
    
    @name = name
    @backtor_id = Backtor.new_id
    @__backtor_special_main = __backtor_special_main

    @thread = Thread.new do
      unless __backtor_special_main
        # TODO: send parameters the proper way, see spec
        # TODO: exceptions
        Backtor.yield(self.instance_exec(*args, &block))
      end
    end
    @thread.abort_on_exception = true
    @thread.instance_variable_set(:@backtor, self)

    @incoming_queue = []
    @incoming_queue_mutex = Mutex.new
    @incoming_queue_cv = ConditionVariable.new
    @outgoing_port = Concurrent::Channel.new
  end

  MAIN = Backtor.new(__backtor_special_main: true) {}

  # TODO: proper clone behaviour like real ractors

  def send(obj)
    @incoming_queue_mutex.synchronize do
      @incoming_queue << obj
      @incoming_queue_cv.signal
    end
  end
  alias << send

  def self.recv
    mutex = Thread.current.instance_variable_get(:@backtor).instance_variable_get(:@incoming_queue_mutex)

    mutex.synchronize do
      queue = Thread.current.instance_variable_get(:@backtor).instance_variable_get(:@incoming_queue)
      cv = Thread.current.instance_variable_get(:@backtor).instance_variable_get(:@incoming_queue_cv)

      cv.wait(mutex) if queue.empty?
      queue.shift
    end
  end

  def take
    @outgoing_port.take
  end

  def self.yield(obj)
    Thread.current.instance_variable_get(:@backtor).instance_variable_get(:@outgoing_port).put(obj)
  end

  def inspect
    "#<Backtor:##{@backtor_id} #{status}>"
  end

  def self.current
    if Thread.current == Thread.main
      Backtor::MAIN
    elsif !Thread.current.instance_variable_get(:@backtor).nil?
      Thread.current.instance_variable_get(:@backtor)
    else
      raise 'current thread is not main nor a backtor'
    end
  end

  def status
    return "running" if @__backtor_special_main
    
    case @thread.status
    when "run"
      "running"
    when false
      "terminated"
    else
      "unimplemented"
    end
  end

  attr_reader :name
end
