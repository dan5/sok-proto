require 'sinatra'
require './app_helper'

class Unit
  attr_accessor :str, :agi, :vit, :img

  def initialize
    @str = rand(6) + 1
    @agi = rand(6) + 1
    @vit = rand(6) + 1
    @img = [97, 136, 141, 142, 154, 159].sample
  end
end

class User
  attr_reader :units

  def initialize
    @units = Array.new(6) { Unit.new }
  end
end

before { user_load }
after { user_save }

get '/api/unit_add' do
  @user.units.push Unit.new
  redirect R
end

get '/api/unit_delete/:unit_id' do |unit_id|
  @user.units.delete_at unit_id.to_i
  redirect R
end

get '/unit/*' do |idx|
  @unit_idx = idx.to_i
  @unit = @user.units[@unit_idx]
  haml :unit
end

get ('/bar') { haml :bar }
get ('/') { haml :index }

__END__

@@ index
- @user.units.each_with_index do |u, i|
  %a{ href: "#{R}/unit/#{i}" }
    %img{width: 40, src: "#{Root}/images/chara#{u.img}_0.gif?"}
%p= link_to '/bar', '[酒場へ行く]'

@@ unit
%img{ width: 80, src: "#{Root}/images/chara#{@unit.img}_0.gif?" }
%div
  %table
    - { 力: @unit.str, 素早さ: @unit.agi, HP: @unit.vit }.each do |k, v|
      %tr
        %td= k
        %td= v
%p= link_to "/api/unit_delete/#{@unit_idx}", '[解雇]'
%p= link_to '/', '[戻る]'

@@ bar
%p= link_to '/api/unit_add', '[仲間を加える]'
%p= link_to '/', '[戻る]'

@@ layout
%html
  %link{ rel: "stylesheet", href: "#{Root}/css/destyle.css" }
  %link{ rel: "stylesheet", href: "#{Root}/css/app.css" }
  %meta{ content: "text/html charset=utf-8", 'http-equiv': "content-type" }
  .main
    = yield
