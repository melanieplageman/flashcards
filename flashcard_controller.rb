require 'sinatra'
require 'sequel'

DB = Sequel.postgres('flashcards')
DB.extension :pg_array
class Flashcard < Sequel::Model(DB[:flashcard])
end
class Side < Sequel::Model(DB[:side])
end

class FlashcardApp < Sinatra::Base
  set :logging, true

  get '/' do
    # require 'pry-byebug'
    # binding.pry
    'Welcome to my flashcard app!!'
  end

  #C - create
  post '/flashcard' do
   data = JSON.parse(request.body.read)
   if data['side'].nil?
     halt 400, "Missing 'side'"
   end
   id = Flashcard.insert()
   # TODO: make it so it doesn't require sides
   data['side'].each do |side|
     Side.insert(flashcard_id: id, text: side)
   end
   # is this the usual body to return for the response...a string?
   data['side'].join(', ')
   # how do I give the flashcard location back to the client
  end

  get '/flashcard/' do
    @res = Side.join_table(:inner, DB[:flashcard], [:id])
    erb :table
  end

  # R - retrieve
  get '/flashcard/:id' do |flashcard_id|
    flashcard = Flashcard[flashcard_id]
    if flashcard.nil?
      halt 404, "No flashcard found with id #{flashcard_id}."
    end
    sides = Side.where(flashcard_id: flashcard_id).all
    response = { 'sides' => sides }
    # {
    #   "id": 1234,
    #   "sides": [
    #     {
    #       "id": 234,
    #       "text": "asdf"
    #     },
    #     {
    #       "id": 235,
    #       "text": "test"
    #   ]
    # }
    sides.map do |side|
      side.text
    end.join(', ')
  end

  # U - update
  # TODO: don't have a PUT for flashcard -- only for sides
  put '/flashcard/:id' do |flashcard_id|
    data = JSON.parse(request.body.read)
    if data['side'].nil?
      halt 400, "Missing 'side'"
    end
    side = Side.where(flashcard_id: flashcard_id).all
    side.each { |side| side.delete }
    data['side'].each do |side|
      Side.insert(flashcard_id: flashcard_id, text: side)
    end
    data['side'].join(', ')
  end

  # D - delete
  delete '/flashcard/:id' do
    flashcard_id = params['id']
    flashcard = Flashcard[flashcard_id]
    if flashcard.nil?
      halt 404, "Cannot delete flashcard with id #{flashcard_id} as it does not exist."
    end
    flashcard.delete
    "Deleted flashcard with id #{flashcard_id}."
  end
end
