require 'sequel'

DB = Sequel.postgres('flashcards')
DB.extension :pg_array

class Flashcard < Sequel::Model(DB[:flashcard])
  one_to_many :sides

  def next
    Flashcard.where do |o|
      o.id > id
    end.first
  end
end

module WithPK
  attr_accessor :pk
end

class Side < Sequel::Model(DB[:side])
  many_to_one :flashcard

  def self.with_pk!(pk)
    super
  rescue Sequel::NoMatchingRow => e
    e.extend(WithPK)
    e.pk = pk
    raise e
  end

  # @return [Side] the next side in the same flashcard
  def next
    next_side = flashcard.sides_dataset.where do |o|
      o.id > id
    end.first

    return next_side unless next_side.nil?

    next_flashcard = flashcard.next
    return nil if next_flashcard.nil?

    next_flashcard.sides_dataset.first
  end
end
