class Static
  def initialize(app)
    @app = app
    @file_server = FileServer.new('public')
  end

  def call(env)
    # puts Dir.pwd
    req = Rack::Request.new(env)
    path = req.path
    # path = Dir.pwd + path
    #
    # puts path
    # file = File.read(path)
    # res = Rack::Response.new(env)
    # res.write(file)
    if path.index('/public')
      @file_server.call(env)
    else
      @app.call(env)
    end
    # res = @file_server.call(env)
    # res
  end


end

class FileServer

  def initialize(root)
    @root = root
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path
    res = Rack::Response.new
    dir = File.dirname(__FILE__)
    if File.exist?(path[1..-1])
      file = File.read(dir + path)
      res['Content-type'] ='text/plain'
      res.write(file)
    else
      res.status = '404'
      res.write('File not found')
    end
    res
  end

end
