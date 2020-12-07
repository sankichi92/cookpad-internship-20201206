require 'sinatra/test_helpers'
require_relative '../app'

RSpec.describe 'PollApp' do
  include Sinatra::TestHelpers

  before do
    set_app Sinatra::Application
    $polls = []
  end

  describe 'GET /' do
    it 'responds 200 OK' do
      get '/'

      expect(last_response.status).to eq 200
    end
  end

  describe 'GET /polls/new' do
    it 'resonds 200 OK' do
      get '/polls/new'

      expect(last_response.status).to eq 200
    end
  end

  describe 'POST /polls/new' do

    context 'with valid title and candidates' do
      it 'create a new poll and redirect to /' do
        expect {
        post '/polls/new', { title: "Example Poll", candidates: ["a", "b", "c"] }
      }.to change { $polls.length }.by(1)

        expect(last_response.status).to eq 303
        expect(last_response.headers['Location']).to match %r{/$}
      end
    end

  end

  describe 'GET /polls/:id' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id' do
      it 'responds 200 OK' do
        get '/polls/0'

        expect(last_response.status).to eq 200
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        get '/polls/1'

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'GET /polls/:id/result' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }
    before do
      $polls = [poll]
    end

    context 'with valid id' do
      it 'responds 200 OK' do
        get '/polls/0/result'

        expect(last_response.status).to eq 200
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        get '/polls/1/result'

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'POST /polls/:id/votes' do
    let(:polls) { [
      Poll.new('Example Poll', ['Alice', 'Bob']),
      Poll.new('Expired Poll', ['Alice', 'Bob'], Time.now - 10),

    ]
    }

    before do
      $polls = polls
    end

    context 'with valid id and params' do
      it 'adds a vote and redirects to /polls/:id' do
        expect {
          post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'Alice' }
        }.to change { polls[0].votes.size }.by(1)

        expect(last_response.status).to eq 303
        expect(last_response.headers['Location']).to match %r{/polls/0$}
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        expect {
          post '/polls/2/votes', { voter: 'Miyoshi', candidate: 'Alice' }
        }.not_to change { polls[1].votes.size }

        expect(last_response.status).to eq 404
      end
    end

    context 'with invalid params' do
      it 'responds 400 Bad Request' do
        expect {
          post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
        }.not_to change { polls[0].votes.size }

        expect(last_response.status).to eq 400
      end
    end

    context 'with invalid time' do
      it 'responds 400 Bad Request' do
        expect {
          post '/polls/1/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
        }.not_to change { polls[1].votes.size }

        expect(last_response.status).to eq 400
      end
    end
  end
end
