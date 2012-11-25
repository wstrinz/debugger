debugger

@should_break = false

t = Thread.new do
  while !@should_break
    A.new.a
    sleep 0.1
  end
end

class A
  def a
    b
  end
  def b
    c
    2
  end
  def c
    d
    3
  end
  def d
    5
  end
end

A.new.a
@should_break = true
t.join
