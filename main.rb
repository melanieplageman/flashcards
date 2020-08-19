unless $LOAD_PATH.include?(File.expand_path('..'))
  $LOAD_PATH.unshift(File.expand_path('..', __FILE__))
end

require 'sinatra'
require 'flashcard_controller'
require 'side_controller'

set :run, false

class Main < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 8080

  use FlashcardApp
  use SideApp
end
Main.run!
