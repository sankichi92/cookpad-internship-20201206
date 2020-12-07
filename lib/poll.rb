class Poll
  class InvalidCandidateError < StandardError
  end

  class InvalidVoteTimeError < StandardError
  end

  attr_reader :title, :candidates, :votes, :deadline

  def initialize(title, candidates, deadline = nil)
    @title = title
    @candidates = candidates
    @votes = []
    @deadline = deadline
  end

  def add_vote(vote)
    unless candidates.include?(vote.candidate)
      raise InvalidCandidateError, "Candidate '#{vote.candidate}' is invalid"
    end

    if deadline != nil && Time.now > deadline
      raise InvalidVoteTimeError
    end

    @votes.push(vote)
  end

  def count_votes
    result = {}

    candidates.each do |candidate|
      result[candidate] = 0
    end

    votes.each do |vote|
      result[vote.candidate] += 1
    end

    result.sort_by { |_, val| val }.reverse.to_h
  end
end
