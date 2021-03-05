require 'haml'
require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  haml :index
end

__END__

@@ index

hello!
