require 'sinatra'
require 'database'

class SideApp < Sinatra::Base
  set :show_exceptions, :after_handler
  set :logging, true

  error Sequel::NoMatchingRow do |e|
    if e.respond_to?(:pk)
      halt 404, "No side with id #{e.pk}"
    else
      halt 404, 'No side'
    end
  end

  error Sequel::ForeignKeyConstraintViolation do
    halt 404, "Flashcard not found"
  end

  # R - Retrieve
  get '/side/:id' do |id|
    @side = Side.with_pk!(id)
    @next_side = @side.next
    erb :side
  end

  # C - Create
  post '/flashcard/:flashcard_id/side' do |flashcard_id|
    side = JSON.parse(request.body.read)
    side_text = side["text"]
    side_id = Side.insert(flashcard_id: flashcard_id, text: side_text)
    response = {side_id: side_id, side_text: side_text}
    headers "Location" => "/flashcard/#{flashcard_id}/side/#{side_id}"
    body response.to_json
  end

  # D - Delete
  delete '/side/:id' do |side_id|
    side = Side[side_id]
    if side.nil?
      halt 404, 'Side not found'
    end
    side.delete
    'Deleted side.'
  end

  # U - update (to update a flashcard, use multiple PUT sides)
  put '/side/:id' do |side_id|
    side = Side[side_id]
    if side.nil?
      halt 404, 'Side not found'
    end
    updated_side = JSON.parse(request.body.read)
    updated_text = updated_side["text"]
    Side[side_id].update(text: updated_text)
    response = {text: updated_text}
    response.to_json
  end
end
