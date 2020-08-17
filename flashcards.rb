require 'http'
require 'json'
# require 'optparse'

class Flashcard
  def initialize(sides)
    @sides = sides
  end

  def to_json
    flashcard_attributes = {
      :sides => @sides, 
    }
    JSON.generate(flashcard_attributes)
  end
end

# options = {}
# OptionParser.new do |opts|
#   opts.banner = "Usage: flashcards.rb [options]"

#   opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
#     options[:verbose] = v
#   end
# end.parse!

# options.each do |o|
#   puts o
# end

flashcard = Flashcard.new(ARGV)
#puts flashcard.to_json

response = HTTP.post("http://localhost:8080/flashcard", :body => flashcard.to_json)
# puts response.body
id = 2
# response = HTTP.get("http://localhost:8080/flashcard/#{id}")

# response = HTTP.put("http://localhost:8080/flashcard/#{id}", :body => flashcard.to_json)

# response = HTTP.delete("http://localhost:8080/flashcard/#{id}") 
puts response
