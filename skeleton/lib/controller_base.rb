require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    !!@already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise 'Already built response'
    else
      @res['Location'] = url
      @res.status = 302
      @already_built_response = true
      session.store_session(res)
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise 'Already built response'
    else
      @res['Content-Type'] = content_type
      @res.write(content)
      @already_built_response = true
      session.store_session(res)
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    path = File.join(controller_name, template_name.to_s)
    eval = ERB.new(File.read("views/#{path}.html.erb")).result(binding)
    render_content(eval, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

