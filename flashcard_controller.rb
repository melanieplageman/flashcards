require 'sinatra'
require 'sequel'

set :bind, '0.0.0.0'
set :port, 8080

DB = Sequel.postgres('flashcards')
DB.extension :pg_array
class Flashcard < Sequel::Model(DB[:flashcard])
end

class FlashcardApp < Sinatra::Base
  set :logging, true
  set :bind, '0.0.0.0'
  set :port, 8080

  get '/' do
    'Hello Worlds!!'
  end

  #C - create
  post '/flashcard' do
    data = JSON.parse(request.body.read)
    Flashcard.insert(sides: Sequel.pg_array(data['sides']))
    data.to_json
  end

  get '/flashcard/' do
    @res = Flashcard.all
    erb :table
  end

  # R - retrieve
  get '/flashcard/:id' do |id|
    @res = Flashcard[id]
    if @res.nil?
      halt 404, "No flashcard found with id #{id}."
    end
    @res.sides.to_s
  end

  # U - update
  put '/flashcard/:id' do |id|
    data = JSON.parse(request.body.read)
    flashcard = Flashcard[id]
    flashcard.update(sides: Sequel.pg_array(data['sides']))
    flashcard.sides.to_s
  end

  # D - delete
  delete '/flashcard/:id' do
    id = params['id']
    @res = Flashcard[id]
    if @res.nil?
      halt 404, "Cannot delete flashcard with id #{id} as it does not exist."
    end
    @res.delete
    "Deleted flashcard with id #{id}."
  end
end
