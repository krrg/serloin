class MagicBlackBoxParameters
  attr_reader :currentUser
  attr_reader :currentQuestion
  attr_reader :adjacencyGraphData
  attr_reader :currentTime

    def initialize(currentUser, currentQuestion, adjacencyGraphData, currentTime)
        @currentUser = currentUser
        @currentQuestion = currentQuestion
        @adjacencyGraphData = adjacencyGraphData
        @currentTime = currentTime
    end
end




class MagicBlackBoxCurrentUser
  attr_reader :tagReputationHash
  attr_reader :reputation
	def initialize(tagReputationHash, reputation)
		@tagReputationHash = tagReputationHash
		@reputation = reputation
	end
end

class MagicBlackBoxCurrentQuestion
  attr_reader :tagsSet   # A collection of tags on the question
  attr_reader :upvotesOfAnswersWithoutFlagsList  # The upvote of answers, maybe sorted.
  attr_reader :creationTime  # The creation time in epoch
  attr_reader :bountyAvailable  # True / False
  attr_reader :numberOfFlags  # i.e. is it closed
  attr_reader :questionUpvotes  # Duh Ken
  attr_reader :pageViews  # Can we get this?
  attr_reader :questionCreatorReputation  # rep of the asker
  attr_reader :questionIsClosedForAnswers  # is it closed? (boolean)
	attr_reader :questionId
	def initialize(tagsSet, upvotesOfAnswersWithoutFlagsList, creationTime,
				bountyAvailable, numberOfFlags, questionUpvotes, pageViews,
				questionCreatorReputation, questionIsClosedForAnswers, questionId)

		@tagsSet = tagsSet
		@upvotesOfAnswersWithoutFlagsList = upvotesOfAnswersWithoutFlagsList
		@creationTime = creationTime
		@bountyAvailable = bountyAvailable
		@numberOfFlags = numberOfFlags
		@questionUpvotes = questionUpvotes
		@pageViews = pageViews
		@questionCreatorReputation = questionCreatorReputation
		@questionIsClosedForAnswers = questionIsClosedForAnswers
		@questionId = questionId
	end

end

class MagicBlackBoxAdjacencyGraphData
  attr_reader :adjacencyGraphData

	def initialize(currentUser, currentQuestion, actualAdjacencyGraph)
        @adjacencyGraphData = Hash.new

		currentUser.tagReputationList.keys each do |tag|
			currentQuestion.tagsSet.keys each do |qtag|
				adjacencyGraphData[tag] += getValueFromAdjacencyGraph(tag, qtag)
			end
		end

  end

  def getValueFromAdjacencyGraph(tag, qtag)
     Graph.upvotes_for_tags(tag, qtag)
  end
end
