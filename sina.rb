# -*- coding: utf-8 -*-
require "rubygems"
require "bundler/setup"
Bundler.require # require all the bundled libs at once.
require File.expand_path('../config', __FILE__)

require 'erb'

set :sessions, true
enable :sessions

before do
  @consumer = OAuth::Consumer.new(
    $secret.hatena.consumer_key,
    $secret.hatena.consumer_secret,
    :site               => '',
    :request_token_path => 'https://www.hatena.com/oauth/initiate',
    :access_token_path  => 'https://www.hatena.com/oauth/token',
    :authorize_path     => 'https://www.hatena.ne.jp/oauth/authorize')
end

get '/' do
  erb :index
end

# リクエストトークン取得から認証用URLにリダイレクトするためのアクション
get '/oauth' do
  # リクエストトークンの取得
  request_token = @consumer.get_request_token(
    { :oauth_callback => 'http://localhost:4567/oauth_callback' },
    :scope          => 'read_public,write_public')

  # セッションへリクエストトークンを保存しておく
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret

  # 認証用URLにリダイレクトする
  redirect request_token.authorize_url
end

# 認証からコールバックされ、アクセストークンを取得するためのアクション
get '/oauth_callback' do
  request_token = OAuth::RequestToken.new(
    @consumer,
    session[:request_token],
    session[:request_token_secret])

  # リクエストトークンとverifierを用いてアクセストークンを取得
  access_token = request_token.get_access_token(
    {},
    :oauth_verifier => params[:oauth_verifier])

  session[:request_token] = nil
  session[:request_token_secret] = nil

  # アクセストークンをセッションに記録しておく
  session[:access_token] = access_token.token
  session[:access_token_secret] = access_token.secret

  erb :oauth_callback, :locals => { :access_token => access_token }
end

# アクセストークンを利用して、OAuthに対応したAPIを利用するためのアクション
get '/hello' do
  access_token = OAuth::AccessToken.new(
    @consumer,
    session[:access_token],
    session[:access_token_secret])

  # access_tokenなどを使ってAPIにアクセスする
  response = access_token.request(:get, 'http://n.hatena.com/applications/my.json')
  if response
    data = JSON.parse(response.body)
  else
    data = ""
  end

  erb :hello, :locals => { :data => data }
end

__END__

@@ index
<p><a href="/oauth">Hatena</a></p>

<% if session[:access_token] && session[:access_token_secret] %>
  <a href="/hello">hello oauth api.</a>
<% end %>

@@ oauth_callback
<p>success getting access_token.</p>

<p>your access token is below.</p>

<dl>
  <dt>access_token</dt>
  <dd><%= access_token.params[:oauth_token] %></dd>
  <dt>access_token_secret</dt>
  <dd><%= access_token.params[:oauth_token_secret] %></dd>
</dl>

<a href="/">back to top</a>

@@ hello
<p>hello oauth!</p>
<dl>
  <dt>url_name</dd>
  <dd><%= data["url_name"] %></dd>
  <dt>display_name</dt>
  <dd><%= data["display_name"] %></dd>
</dl>
