# A class body between a method's def and a later include calls the
# method, so the call in its body runs before the include. It reaches
# Animal#speak in CRuby ("..."); Spinel's one chain, the last, would answer
# "kind"; refused.
puts "boot"
module Kind
  def speak = "kind"
end
class Animal
  def speak = "..."
end
class Cat < Animal
end
def talk(c) = c.speak
class Runner
  puts talk(Cat.new)
end
class Cat
  include Kind
end
puts talk(Cat.new)
