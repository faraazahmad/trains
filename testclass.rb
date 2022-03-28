class Test
  attr_accessor :name, :age

  def initialize(name, age)
    self.name = name
    self.age = age
  end

  def say_hello
    puts "I am #{name} and I am #{age} years old"
  end
end
