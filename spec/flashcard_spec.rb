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
    # is this the right behavior
    it "Retrieves flashcard sides given a valid flashcard id" do
      flashcard_id = Flashcard.insert()
      sides_data = ["more", "and", "more", "more", "and", "more"]
      sides_data.each do |side|
        Side.insert(flashcard_id: flashcard_id, text: side)
      end
      get("/flashcard/#{flashcard_id}")
      expect(last_response.body).to eq(sides_data.join(', '))
      expect(last_response.status).to eq(200)
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
      expect(last_response.body).to be_empty
    end
  end

  describe 'PUT /flashcard/:id' do
    it "Updates a flashcard given a valid flashcard id" do
      flashcard_id = Flashcard.insert()
      Side.insert(flashcard_id: flashcard_id, text: 'more')
      body = { 'side' => ['less'] }.to_json
      put("/flashcard/#{flashcard_id}", body)
      expect(last_response.body).to eq('less')
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
    # TODO: make it so that a flashcard can be made without making sides
    context "when 'side' is missing" do
      it "responds with 400 and an appropriate error message" do
        post('/flashcard', { test: 'test-string' }.to_json)
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq("Missing 'side'")
      end

      it "doesn't create a record" do
        expect do
          post('/flashcard', { test: 'test-string' }.to_json)
        end.to_not change { Flashcard.count }
      end
    end


    context "when 'side' is present" do
      it "Creates a flashcard" do
        body = { 'side' => ["more", "and", "more", "more", "and", "more"] }
        post('/flashcard', body.to_json)
        expect(last_response.status).to eq(200)
        # make an expectation that the flashcard exists at the location specified in header
        # also once we have the flashcard location, we can make an expectation that were we to visit it we can see the sides
        # todo: make this a separate test
        expect(last_response.body).to eq(body['side'].join(', '))
      end
    end
  end
end
