TRUNCATE flashcard CASCADE;

INSERT INTO flashcard(id) VALUES
  (1),
  (2),
  (3),
  (4);

INSERT INTO side(flashcard_id, text, format) VALUES
  (1, 'make a flashcard class', 'text'),
  (1, 'class FlashcardApp ; end', 'ruby'),
  (2, 'check if a variable is nil', 'text'),
  (2, 'variable.nil?', 'ruby'),
  (3, 'what is a homoiconic language', 'text'),
  (3, 'hard question', 'text'),
  (4, 'make a dictionary', 'text'),
  (4, 'mydict = { ''key'' => ''value'', ''key2'' => ''value2'' }', 'ruby');
