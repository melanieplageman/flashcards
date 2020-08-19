require 'sinatra'
require 'sequel'

require 'side_controller'

DB = Sequel.postgres('flashcards')
DB.extension :pg_array

class Flashcard < Sequel::Model(DB[:flashcard])
end

module WithPK
  attr_accessor :pk
end

class Side < Sequel::Model(DB[:side])
  def self.with_pk!(pk)
    super
  rescue Sequel::NoMatchingRow => e
    e.extend(WithPK)
    e.pk = pk
    raise e
  end
end

class FlashcardApp < Sinatra::Base
  set :logging, true

  get '/' do
    'Welcome to my flashcard app!!'
  end

  #C - create
  post '/flashcard' do
   flashcard_id = Flashcard.insert()
   headers \
     "Location" => "0.0.0.0:80/flashcard/#{flashcard_id}"
   body 'something'
  end

  # R - retrieve
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
    response = { 'id' => flashcard_id, 'sides' => [] }
    sides = Side.where(flashcard_id: flashcard_id).all
    sides.each do |side|
      response['sides'] << { 'id' => side.id, 'text' => side.text }
    end
    body response.to_json
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
