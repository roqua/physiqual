# From: http://blog.pivotal.io/labs/labs/writing-rails-engine-rspec-controller-tests
module EngineControllerPatch
  def get(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, 'GET')
  end

  # Executes a request simulating POST HTTP method and set/volley the response
  def post(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, 'POST')
  end

  # Executes a request simulating PUT HTTP method and set/volley the response
  def put(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, 'PUT')
  end

  # Executes a request simulating DELETE HTTP method and set/volley the response
  def delete(action, parameters = nil, session = nil, flash = nil)
    process_action(action, parameters, session, flash, 'DELETE')
  end

  private

  def process_action(action, parameters = nil, session = nil, flash = nil, method = 'GET')
    parameters ||= {}
    if Rails::VERSION::MAJOR < 4
      process(action, parameters.merge!(use_route: :physiqual), session, flash, method)
    else
      process(action, method, parameters.merge!(use_route: :physiqual), session, flash)
    end
  end
end
