require 'sinatra'
require 'pg'


set :bind, '0.0.0.0'
set :port, 8080

get '/' do
  'Hello Worlds!!'
end

# C - create
post '/flashcard' do
  data = JSON.parse(request.body.read)
  begin
    connection = PG.connect(dbname: 'flashcards')

    # flashcards (id, sides)
    connection.exec_params(
      'INSERT INTO flashcard (sides) VALUES ($1);', [
      PG::TextEncoder::Array.new.encode(data['sides'])
      ])
  end
end

# S - select
get '/flashcard/' do
  connection = PG.connect(dbname: 'flashcards')
  @res = connection.exec('SELECT id, sides FROM flashcard;')
  erb :table
end

# R - retrieve
get '/flashcard/:id' do
  id = params['id']
  connection = PG.connect(dbname: 'flashcards')
  @res = connection.exec_params('SELECT id, sides FROM flashcard where id = $1;', [id])
  @res[0]['sides'].to_s
end

# U - update
put '/flashcard/:id' do
  data = JSON.parse(request.body.read)
  connection = PG.connect(dbname: 'flashcards')
  @res = connection.exec_params('UPDATE flashcard SET sides = $1 WHERE id = $2;', 
        [PG::TextEncoder::Array.new.encode(data['sides']), params['id']])
end

# D - delete
delete '/flashcard/:id' do
  id = params['id']
  connection = PG.connect(dbname: 'flashcards')
  @res = connection.exec('DELETE FROM flashcard where id = $1 RETURNING *;', [id]);
  @res[0]['sides'].to_s
end
