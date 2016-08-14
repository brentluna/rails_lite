require 'singleton'

class Application
  include Singleton

  def initialize
  end

  def self.router
    @@router ||= Router.new
  end

end

class Railslite < Application
end
