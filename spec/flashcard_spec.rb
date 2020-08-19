ENV['APP_ENV'] = 'test'

require 'flashcard_controller'
require 'rack/test'

describe FlashcardApp do
  include Rack::Test::Methods
  def app
    FlashcardApp
  end

  before do
    Flashcard.truncate(cascade: true)
  end


  describe 'GET /flashcard/' do
    it "Retrieves all flashcards with their sides" do
      get('/flashcard/')
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /flashcard/:id' do
    it "Retrieves flashcard sides given a valid flashcard id" do
      flashcard_id = Flashcard.insert()
      sides_data = ["more", "and", "more", "more", "and", "more"]
      sides_data.each do |side|
        Side.insert(flashcard_id: flashcard_id, text: side)
      end
      get("/flashcard/#{flashcard_id}")
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      response_sides = []
      response['sides'].map do | s |
        response_sides << s['text']
      end
      expect(response_sides).to eq(sides_data)
    end

    it "Fails with 404 if a flashcard with the specified id is not found" do
      get("/flashcard/1")
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("No flashcard found with id 1.")
    end

    it 'returns 200 on a flashcard with no side' do
      id = Flashcard.insert()
      get("/flashcard/#{id}")
      expect(last_response.status).to eq(200)
    end
  end

  describe 'DELETE /flashcard/:id' do
    it "Deletes a specific flashcard given a valid id" do
      flashcard_id = Flashcard.insert
      delete("/flashcard/#{flashcard_id}")
      expect(Flashcard[flashcard_id]).to be(nil)
      expect(last_response.body).to eq("Deleted flashcard with id #{flashcard_id}.")
    end
  end

  describe 'POST /flashcard' do
    context "when 'side' is present" do
      it "Creates a flashcard" do
        body = { 'side' => ["more", "and", "more"] }
        post('/flashcard', body.to_json)
        expect(last_response.status).to eq(200)
        expect(last_response.headers['location']).to_not be(nil)
      end

      it "creates a record" do
        expect do
          post('/flashcard', { test: 'test-string' }.to_json)
        end.to change { Flashcard.count }
      end
    end
  end
end
