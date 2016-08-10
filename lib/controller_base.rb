require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params={})
    @params = params
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "dobule redirect" if already_built_response?
    @res['Location'] = url
    @res.status = 302

    @already_built_response = true
    flash.store_flash(@res)
    session.store_session(@res)
    nil

  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Double Render' if already_built_response?

    @res['Content-Type'] = content_type
    @res.write(content)

    @already_built_response = true
    flash.store_flash(@res)
    session.store_session(@res)
    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    file = "views/#{self.class.name.underscore}/#{template_name}.html.erb"

    template = File.read(file)
    erb = ERB.new(template).result(binding)
    render_content(erb, 'text/html')

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end
  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
