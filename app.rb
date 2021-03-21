require 'sinatra'
require './app_helper'

Monsters = %w(m1 m2 m3)

class Unit
  attr_accessor :str, :agi, :vit, :hp, :img
  def alive?() hp > 0 end
  def dead?() hp <= 0 end
  def monster?() /m/.match @id.to_s end
  def name() "unit_#{@id}" end

  def initialize(id)
    @id = id
    @str = rand(6) + 1
    @agi = rand(6) + 1
    @vit = rand(6) + 1
    @hp = vit
    @img = [0, 6, 56, 57, 58, 63].sample
  end

  def act(units)
    "#{name}(#{hp})の攻撃 -> " +
      if t = units.select(&:alive?).select {|e| monster? != e.monster? }.sample
        t.damage str
        "#{t.name} -> ダメージ#{str}#{t.dead? ? ' DEAD' : ''}"
      else
        ''
      end
  end

  def damage(d)
    @hp = [@hp - d, 0].max
  end
end

class User
  attr_reader :units, :monsters

  def initialize
    @units = Array.new(6) {|i| Unit.new i }
    @monsters = Monsters.map {|e| Unit.new e }
  end
end

before { user_load }
after { user_save }

get '/api/unit_add' do
  @user.units.push Unit.new @user.units.size
  redirect R
end

get '/api/unit_delete/:unit_id' do |unit_id|
  @user.units.delete_at unit_id.to_i
  redirect R
end

get '/api/battle/*' do |monster_id|
  session[:logs] = []
  a = (@user.units + @user.monsters[monster_id.to_i, 1]).select &:alive?
  a.sort_by(&:agi).reverse.each do |e|
    session[:logs] << e.act(a) if e.alive?
  end
  @user.units.delete_if &:dead?
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
%table
  %tr
    - @user.units.each_with_index do |u, i|
      %td
        %a{ href: "#{R}/unit/#{i}" }
          %img{width: 40, src: "#{Root}/images/chara#{u.img}_0.gif?"}
        .status #{u.hp}/#{u.vit}

%p= link_to '/bar', '[酒場へ行く]'

%table
  %tr
    - @user.monsters.each_with_index do |u, i|
      %td
        %a{ href: "#{R}/api/battle/#{i}" }
          %img{width: 80, src: "#{Root}/images/mons#{i}_0.gif?"}
        .status #{u.hp}/#{u.vit}

%p= (session[:logs] or []).join("<br />")

@@ unit
- u = @unit
%img{ width: 80, src: "#{Root}/images/chara#{u.img}_0.gif?" }
%div
  %table
    - { 名前: u.name, 力: u.str, 素早さ: u.agi, HP: u.vit }.each do |k, v|
      %tr
        %td= k
        %td= v
%p= link_to "/api/unit_delete/#{@unit_idx}", '[解雇]'
%p= link_to '/', '[戻る]'

@@ bar
%p マスター「一杯どうだ？」
%p= link_to '/api/unit_add', '[仲間を加える]'
%p= link_to '/', '[戻る]'

@@ layout
%html
  %link{ rel: "stylesheet", href: "#{Root}/css/destyle.css" }
  %link{ rel: "stylesheet", href: "#{Root}/css/app.css?" }
  %meta{ content: "text/html charset=utf-8", 'http-equiv': "content-type" }
  .main
    = yield
