class App_Helper
  def OK_helper resource, params
    halt 404, '#{resource} not found' if resource.nil?
    halt 400 if params.nil?
    true
  end
end 