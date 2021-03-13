require 'sinatra'
require 'sinatra/cookies'

if 'app.rb' == $0
  require 'sinatra/reloader'
  Root = R = ''
end

helpers do
  def link_to(url, txt = url) %Q|<a href="#{R}#{url}">#{txt}</a>| end

  def password
    cookies[:id] ||= rand(9999_9999_9999).to_s(26)
  end

  def dataname()
    'data/' + password + '.data'
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
