require_relative '../lib/poll'
require_relative '../lib/vote'
require 'pg'

=begin
  データベースにアクセスして投票や票の
  情報を取得する、また票のカウントを
  行うクラス
=end

class Fetch_DB
  attr_reader :host, :database, :user, :polls

  #初期設定（データベースの接続や票の情報の取得）
  def initialize(host, database, user, password)
    @host = host
    @database = database
    @user = user
    @password = password
    @connection = connect(host, database, user, password)
    @polls = get_polls()
  end

  #データベースに接続し、接続情報を返すメソッド
  def connect(host, database, user, password)
    connection = PG::Connection.new(:host => host, :user => user, :dbname => database, :port => '5432', :password => password)
    connection
  end

  #データベースのテーブルを作成するメソッド
  def create_tables()
    sql = File.open('db/create_tables.sql', 'rb') { |file| file.read } #SQLを読み込む
    @connection.exec(sql)
  end

  #投票や票のデータを読み込むメソッド
  def get_polls()
    table_info = @connection.exec("SELECT EXISTS (SELECT * FROM information_schema.tables
                                  WHERE table_name = 'poll');") #テーブルの存在を確認
    
    if  table_info[0]["exists"] == "f" #テーブルが存在しない場合
      create_tables() #テンプレ追加
    end
    
    polls = [] #投票の情報
    poll_res = @connection.exec('SELECT * FROM poll;') #全ての投票の情報を取得
    
    poll_res.each do |poll|
      title = poll["title"]

      candidate_arr = []
      candidate_res = @connection.exec("SELECT * FROM poll_candidate WHERE poll_id = #{ poll["id"] };") #現在の投票の投票候補を取得
      candidate_res.each do |candidate|
        candidate_arr.append(candidate["candidate"]) #投票候補をcandidate_arrに追加する
      end

      p = Poll.new(title, candidate_arr) #現在の投票の情報

      vote_res = @connection.exec("SELECT * FROM vote WHERE poll_id = #{ poll["id"] };") #現在の投票の票を取得
      vote_res.each do |vote|
        p.add_vote(Vote.new(vote["voter"], vote["candidate"])) #票を投票する
      end

      polls.append(p) #現在の投票を追加する
    end

    polls #全ての投票結果を返す
  end

  #票をデータベースに追加するメソッド（次回接続の為）
  def vote(voter, poll_id, candidate)
    @connection.exec("INSERT INTO vote
                     VALUES('#{ voter.to_s }', #{ poll_id }, '#{ candidate }');")
  end
end
