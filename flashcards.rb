require 'http'
require 'json'
# require 'optparse'

class Flashcard
end

class Side
  def initialize(text)
    @text = text 
  end

  def to_json 
    JSON.generate({ :text => @text })
  end
end

def new_flashcard(args)
  response = HTTP.post("http://localhost:8080/flashcard") 
  flashcard_id = JSON.parse(response.body)['id']
  add_side([flashcard_id, *args])
  puts flashcard_id
end

def add_side(args)
  flashcard_id, *args = args
  args.map do |side_text|
    Side.new(side_text)
  end.each do |side|
    response = HTTP.post("http://localhost:8080/flashcard/#{flashcard_id}/side", :body => side.to_json)

    puts JSON.parse(response.body)
  end
end

command, *args = ARGV
if command == 'new'
  new_flashcard(args)
elsif command == 'add'
  add_side(args)
else
  fail "Unrecognized command #{command.inspect}"
end



# response = HTTP.get("http://localhost:8080/flashcard/#{id}")

# response = HTTP.put("http://localhost:8080/flashcard/#{id}", :body => flashcard.to_json)

# response = HTTP.delete("http://localhost:8080/flashcard/#{id}") 
#
#
#

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
