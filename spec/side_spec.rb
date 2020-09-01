ENV['APP_ENV'] = 'test'

require 'side_controller'
require 'flashcard_controller'
require 'rack/test'

describe SideApp do
  include Rack::Test::Methods
  def app
    SideApp 
  end

  before do
    Flashcard.truncate(cascade: true)
  end

  describe 'GET /side/:id' do
    it "retrieves a side given a valid side locator" do
      flashcard_id = Flashcard.insert
      side_id = Side.insert(flashcard_id: flashcard_id, text: "something")
      get("/side/#{side_id}")
      expect(last_response.status).to eq(200)
    end

    it 'fails with 404 if the side does not exist' do
      get('/side/1234')
      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq('No side with id 1234')
    end
  end

  describe 'POST /flashcard/:flashcard_id/side' do
    it "Creates a new side for a flashcard given a valid flashcard id" do
      flashcard_id = Flashcard.insert
      body = { text: 'something' } 
      post("/flashcard/#{flashcard_id}/side", body.to_json)
      expect(last_response.status).to eq(200)
      side_id = JSON.parse(last_response.body)["side_id"]
      side_text = JSON.parse(last_response.body)["side_text"]
      expect(side_text).to eq(body[:text])
      ds_side = Side[side_id]
      expect(ds_side.text).to eq(side_text)
    end

    it "Fails with 404 if the flashcard does not exist" do
      body = { text: 'something' } 
      post("/flashcard/1234/side", body.to_json)
      expect(last_response.status).to eq(404)
    end
  end

  describe 'DELETE /side/:id' do
    it "Deletes a side given a valid side locator" do
      flashcard_id = Flashcard.insert
      side_id = Side.insert(flashcard_id: flashcard_id, text: "something")
      delete("/side/#{side_id}")
      expect(Side[side_id]).to be(nil)
      expect(last_response.body).to eq('Deleted side.')
    end

    it 'Fails with 404 if the side does not exist' do
      delete('/side/1234')
      expect(last_response.status). to eq(404)
    end
  end

  describe 'PUT /side/:id' do
    it 'Updates an existing side given a valid side locator' do
      flashcard_id = Flashcard.insert
      side_id = Side.insert(flashcard_id: flashcard_id, text: 'something')
      body = { text: 'something_else' } 
      put("/side/#{side_id}", body.to_json)
      side_text = JSON.parse(last_response.body)["text"]
      expect(side_text).to eq(body[:text])
      expect(Side[side_id].text).to eq(body[:text])
    end
  end
end
