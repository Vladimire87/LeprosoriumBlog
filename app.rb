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
		"content" text,
		"author" text
	)
	SQL

	@db.execute <<-SQL 
	CREATE TABLE IF NOT EXISTS 
	"Comments" 
	(
		"id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
		"created_date" timestamp,
		"content" text,
		"post_id" integer
	)
	SQL
end

get '/' do
	@all_posts = @db.execute 'SELECT * FROM Posts ORDER by id desc'

	erb :index
end

get '/new_post' do
  erb :new_post
end

post '/new_post' do
  @post = params[:post]
	@author = params[:author]

	if @post.empty? || @author.empty?
		@error = "Enter Post Text and Author"
		return erb :new_post
	end
	

	@db.execute("INSERT INTO 'Posts' (created_date, content, author) VALUES (datetime(), ?, ?)", [@post, @author])

	redirect '/'
end

get '/post/:id' do
 id = params[:id]
 result = @db.execute 'SELECT * FROM Posts where id=?', [id]
 @post = result[0]

 @comments = @db.execute 'SELECT * FROM Comments where post_id=? order by id', [id]

 erb :post
end

post '/post/:id' do
	id = params[:id]
	comment = params[:comment]
	@db.execute("INSERT INTO 
		'Comments' 
		(created_date, content, post_id) 
		VALUES (datetime(), ?, ?)", [comment, id])

		redirect to('/post/' + id)
 end