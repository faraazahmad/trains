require 'set'

class Controller
  attr_accessor :name, :controller_methods

  def initialize(name = nil, controller_methods = Set.new)
    @name = name
    @controller_methods = controller_methods
  end
end
