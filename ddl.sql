DROP TABLE IF EXISTS flashcard;
CREATE TABLE flashcard (
  id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  sides text[]
);