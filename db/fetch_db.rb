require_relative '../lib/poll'
require_relative '../lib/vote'
require 'pg'

class Fetch_DB
  attr_reader :host, :database, :user, :polls

  def initialize(host, database, user, password)
    @host = host
    @database = database
    @user = user
    @password = password
    @connection = connect(host, database, user, password)
    @polls = get_polls()
  end

  def connect(host, database, user, password)
    connection = PG::Connection.new(:host => host, :user => user, :dbname => database, :port => '5432', :password => password)
    connection
  end

  def create_tables()
    sql = File.open('./create_tables.sql', 'rb') { |file| file.read }
  end

  def get_polls()
    polls = []
    poll_res = @connection.exec('SELECT * FROM poll;')
    poll_res.each do |poll|
      title = poll["title"]
      candidate_arr = []
      candidate_res = @connection.exec("SELECT * FROM poll_candidate WHERE poll_id = #{poll["id"]};")
      candidate_res.each do |candidate|
        candidate_arr.append(candidate["candidate"])
      end
      p = Poll.new(title, candidate_arr)
      vote_res = @connection.exec("SELECT * FROM vote WHERE poll_id = #{poll["id"]};")
      vote_res.each do |vote|
        p.add_vote(Vote.new(vote["voter"], vote["candidate"]))
      end
      polls.append(p)
    end
    polls
  end

  def vote(voter, poll_id, candidate)
    @connection.exec("INSERT INTO vote
                     VALUES('#{voter.to_s}', #{poll_id}, '#{candidate}');")
  end
end
