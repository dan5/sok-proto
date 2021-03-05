require 'haml'
require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  haml :index
end

__END__

@@ index

- %w(136 97 141 142 154 159).each do |i|
  %img{width: 40, src: "images/chara#{i}_0.gif?"}
