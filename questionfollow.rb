require_relative 'question'
require_relative 'user'
require 'byebug'

class QuestionFollow
  attr_accessor :id, :follower_id, :question_id

  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil unless question_follow.length > 0
    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.follower_id
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        questions.id = ?
    SQL
    return nil unless users.length > 0
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      JOIN
        users ON question_follows.follower_id = users.id
      WHERE
        users.id = ?
    SQL
    return nil unless questions.length > 0
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.title, COUNT(questions.title) AS num_followers
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        num_followers DESC
      LIMIT
        ?
    SQL
    return nil unless questions.length > 0
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @follower_id = options['follower_id']
    @question_id = options['question_id']
  end
end
