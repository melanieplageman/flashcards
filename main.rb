unless $LOAD_PATH.include?(File.expand_path('..'))
  $LOAD_PATH.unshift(File.expand_path('..', __FILE__))
end

require 'flashcard_controller'

FlashcardApp.run!
