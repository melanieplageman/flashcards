ENV['APP_ENV'] = 'test'

require 'flashcard_controller'
require 'rack/test'

describe FlashcardApp do
  include Rack::Test::Methods
  def app
    FlashcardApp
  end

  it "Creates a flashcard" do
    body = { 'sides' => ["more", "and", "more", "more", "and", "more"] }.to_json
    post('/flashcard', body)
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(body)
  end

  it "Retrieves all flashcards" do
    get('/flashcard/')
    expect(last_response.status).to eq(200)
  end

  it "Retrieves a flashcard given a valid id" do
    Flashcard.truncate
    data = ["more", "and", "more", "more", "and", "more"]
    id = Flashcard.insert(sides: Sequel.pg_array(data))
    get("/flashcard/#{id}")
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq(data)
  end

  it "Fails with 404 if a flashcard with the specified id is not found" do
    Flashcard.truncate
    get("/flashcard/1")
    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq("No flashcard found with id 1.")
  end

  it "Updates a flashcard given a valid id" do
    Flashcard.truncate
    data = ["more", "and", "more", "more", "and", "more"]
    id = Flashcard.insert(sides: Sequel.pg_array(data))
    body = { 'sides' => ["less", "and", "less"] }.to_json
    put("/flashcard/#{id}", body)
    updated_data = ["less", "and", "less"]
    expect(Flashcard[id].sides).to eq(updated_data)
    expect(JSON.parse(last_response.body)).to eq(updated_data)
  end

  it "Deletes a specific flashcard given a valid id" do
    Flashcard.truncate
    data = ["more", "and", "more", "more", "and", "more"]
    id = Flashcard.insert(sides: Sequel.pg_array(data))
    delete("/flashcard/#{id}")
    expect(Flashcard[id]).to be(nil)
    expect(last_response.body).to eq("Deleted flashcard with id #{id}.")
  end
end
