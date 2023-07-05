#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
 init_db
end

configure do
	init_db
	@db.execute <<-SQL 
	CREATE TABLE IF NOT EXISTS 
	"Posts" 
	(
		"id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
		"created_date" timestamp,
		"content" text
	)
	SQL
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new_post' do
  erb :new_post
end

post '/new_post' do
  post = params[:post]

	if post.size <= 0
		@error = "Enter Post Text"
		return erb :new_post
	end

	erb "#{post}"
end