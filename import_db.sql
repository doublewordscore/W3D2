DROP TABLE users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE question_follows;
CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  follower_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  reply_author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (subject_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (reply_author_id) REFERENCES users(id)
);

DROP TABLE question_likes;
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('panpan', 'song'),
  ('phil', 'nguyen'),
  ('tommy', 'duek'),
  ('sennacy', 'cat');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('favorite food', 'what''s your favorite fruit?', 1),
  ('treats', 'where''s my treat?', 4);

INSERT INTO
  replies (subject_id, parent_reply_id, reply_author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'favorite food'), NULL,
    (SELECT id FROM users WHERE fname = 'phil' AND lname = 'nguyen'),
    'I like coconuts.');

INSERT INTO
  replies (subject_id, parent_reply_id, reply_author_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'favorite food'),
    (SELECT id FROM replies WHERE reply_author_id = 2),
    (SELECT id FROM users WHERE fname = 'panpan'),
    'I thought you liked mangoes...');

  INSERT INTO
   question_follows (follower_id, question_id)
  VALUES
    (1, 1),
    (2, 1);

  INSERT INTO
    question_likes (user_id, question_id)
  VALUES
    (4, 1), (2, 2), (1, 2), (3, 1), (3, 2);
