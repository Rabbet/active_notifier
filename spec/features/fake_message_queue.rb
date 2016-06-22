class FakeMessageQueue
  cattr_accessor :queue
  self.queue = Hash.new([])

  def lpush(key, value)
    self.class.queue[key].push(value)
  end

  def lpop(key)
    self.class.queue[key].pop
  end

  def llen(key)
    self.class.queue[key].length
  end

  def flushall
    self.class.queue = Hash.new([])
  end
end
