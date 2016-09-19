# Lite Rails

Custome made ite version of Ruby on Rails, with basic rails functionality.

#Technologies

- Ruby
- Rack

I utilized meta programming to create the basic functionlaity of Ruby on Rails using only Ruby. I created a server using rack to replace the Rails supplied webrick. Created middleware to handle such things as exceptions, static file server, CSRF protection and flash errors.

```ruby
require 'erb'

class ShowExceptions
  attr_reader :app
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    render_exception(e)
  end

  private

  def render_exception(e)
    file = "lib/templates/rescue.html.erb"
    template = File.read(file)
    erb = ERB.new(template).result(binding)
    ['500', {'Content-type' => 'text/html'}, [erb]]
  end

end
```

## Todo

- Combine my lite Rails and ActiveRecord projects to create a Ruby/ActiveRecord replacement. (Currently working on this in the combinig branch)
