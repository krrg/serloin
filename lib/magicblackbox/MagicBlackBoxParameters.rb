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
  attr_reader :tagsSet
  attr_reader :upvotesOfAnswersWithoutFlagsList
  attr_reader :creationTime
  attr_reader :bountyAvailable
  attr_reader :numberOfFlags
  attr_reader :questionUpvotes
  attr_reader :pageViews
  attr_reader :questionCreatorReputation
  attr_reader :questionIsClosedForAnswers
	def initialize(tagsSet, upvotesOfAnswersWithoutFlagsList, creationTime, 
				bountyAvailable, numberOfFlags, questionUpvotes, pageViews, 
				questionCreatorReputation, questionIsClosedForAnswers)

		@tagsSet = tagsSet
		@upvotesOfAnswersWithoutFlagsList = upvotesOfAnswersWithoutFlagsList
		@creationTime = creationTime
		@bountyAvailable = bountyAvailable
		@numberOfFlags = numberOfFlags
		@questionUpvotes = questionUpvotes
		@pageViews = pageViews
		@questionCreatorReputation = questionCreatorReputation
		@questionIsClosedForAnswers = questionIsClosedForAnswers
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
	
		#todo: actually get value from graph
		return 9
	end
end