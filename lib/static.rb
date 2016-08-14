class Static
  def initialize(app)
    @app = app
    @file_server = FileServer.new('public')
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if path.index('/public')
      @file_server.call(env)
    else
      @app.call(env)
    end
  
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
