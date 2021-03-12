require 'sinatra'
require 'sinatra/cookies'

helpers do
  def link_to(url, txt = url) %Q|<a href="#{R}#{url}">#{txt}</a>| end

  def dataname()
    'data/' + (cookies[:id] ||= rand(9999_9999_9999).to_s(26)) + '.data'
  end

  def user_load()
    @user = File.open(dataname, 'rb') {|f| Marshal.load f }
  rescue
    @user = User.new
  end

  def user_save()
    File.open(dataname, 'wb') {|f| Marshal.dump @user, f }
  end
end

if 'app.rb' == $0
  require 'sinatra/reloader'
  Root = R = ''
end
