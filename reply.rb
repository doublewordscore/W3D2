require_relative 'question'
require_relative 'user'
require 'byebug'

class Reply
  attr_accessor :id, :subject_id, :parent_reply_id, :reply_author_id, :body

  def initialize(options)
    @id = options['id']
    @subject_id = options['subject_id']
    @parent_reply_id = options['parent_reply_id']
    @reply_author_id = options['reply_author_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_user_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_author_id = ?
    SQL
    debugger
    return nil unless replies.length > 0
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_id = ?
    SQL
    return nil unless replies.length > 0
    replies.map { |reply| Reply.new(reply) }
  end


  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, @reply_author_id)
    SELECT
      *
    FROM
      users
    WHERE
      id = @reply_author_id
    SQL
    return nil unless user.length > 0
    User.new(user.first)
  end


  def question
    q = QuestionsDatabase.instance.execute(<<-SQL, @subject_id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = @subject_id
    SQL
    return nil unless q.length > 0
    Question.new(q.first)
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    return nil unless reply.length > 0
    Question.new(reply.first)
  end

  def save
    if @id
      update
    else
      QuestionsDatabase.instance.execute(<<-SQL, @subject_id, @parent_reply_id, @reply_author_id, @body)
        INSERT INTO
          replies (subject_id, parent_reply_id, reply_author_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @subject_id, @parent_reply_id, @reply_author_id, @body, @id)
      UPDATE
        replies
      SET
        subject_id = ?, parent_reply_id = ?, reply_author_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end

end
