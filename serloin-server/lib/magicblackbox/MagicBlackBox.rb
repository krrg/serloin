class MagicBlackBoxCategory

	def initialize(name, weight, maxValue, children, calculationFunction)
		@name = name
		@weight = weight
		@maxValue = maxValue
		@children = children
		@calculationFunction = calculationFunction
	end
	
	def calculateWeightedScore(value)
		normalizedValue = value / @maxValue
		totalWeighting = @weight
		
		weightedScore = value * totalWeighting
	end
	
end


class MagicBlackBox

	def calculateRecency()
		minTimeThreshold = 60
		highTimeThreshold = 60 * 20 

		deltaTime = @currentTime - @currentQuestion.creationTime

		if deltaTime < minTimeThreshold
			return 1
		elsif deltaTime >highTimeThreshold
			return 0
		else
			return 1 - (deltaTime/highTimeThreshold)
		end
	end
  	def calculateNotAnswered()
		
	  	pointsThreshold = 25

		if @currentQuestion.numberOfFlags == 0
			return 1
		end

		score = 0

		@allAnswersWithoutFlags.each do |answer|

			if answer.points >= pointsThreshold
				score = score + 0.5
			elsif answer.points >= Math.sqrt(pointsThreshold)
				score = score + 0.5 * (answer.points/pointsThreshold)
			else
				score = score + 0.1 * (answer.points/pointsThreshold)
			end
		end

		endValue = 1 - score
		if endValue < 0
			endValue = 0
		end

		return endValue
	end
	
	def calculateBountyAvailable()
		if @currentQuestion.bountyAvailable == true
			return 1
		end

		return 0
	end
	
	def calculateQuestionQuality()
		flagThreshold = 3
		repThreshold = 10
		
		flagWeight = 0.5
		repWeight = 0.5

		if @currentQuestion.numberOfFlags == 0 && @questionCreator.rep >=repThreshold
			return 1
		end

		if @currentQuestion.numberOfFlags >= flagThreshold || @questionCreator.rep <0
			return 0
		end

		flagScore = flagWeight* @currentQuestion.numberOfFlags/flagThreshold
		repScore = repWeight* (repThreshold - @questionCreator.rep)/repThreshold

		endValue = 1 - (flagScore + repScore)
		return endValue
	end
	
  	def calculateQuestionDifficulty()
		pointThreshold = 10
		pageViewThreshold = 100

		answerPointWeight = 0.5
		repWeight = 0.5

		answerPointScore = 0
		repScore = 0

		answerExistsAboveThreshold = false
		@allAnswersWithoutFlags.each do |answer|
			if answer.points >= pointThreshold
				answerExistsAboveThreshold = true
			end
		end

		if @allAnswersWithoutFlags == false
			if @currentQuestion.pageViews >= pointThreshold
				answerPointScore = 1
			else
				answerPointScore = 0.5
			end
		else
			if currentQuestion.pageViews >= pointThreshold
				answerPointScore = 0.5
			else
				answerPointScore = 0
			end
		end

		if @currentUser.rep >= @questionCreator.rep * 100
			repScore = 0
		elsif @currentUser.rep >= @questionCreator.rep * 10
			repScore = 0.25
		elsif @currentUser.rep >= @questionCreator.rep
			repScore = 0.50
		elsif @currentUser.rep * 10 >= @questionCreator.rep
			repScore = 0.75
		else
			repScore = 1
		end

		difficultyScore = repWeight*repScore + answerPointWeight *answerPointScore
		easinessScore = 1 - difficultyScore

		return easinessScore
	end
	
	def calculateQuestionRelevance()
		#do nothing
		
	end
	
	def getValueFromAdjacencyGraph(tag, qtag)
	{
		#todo: actually get value from graph
		return 9
	}

	def calculateTagRelevance()
		#n = @currentUser.tagList.Count
		#G = @adjacencyGraph
		#UTAGS = @currentUser.tagRepList.keys
		#QTAGS  = @currentQuestion.tagList

		P = Hash.new
		totalRep = 0

		#UTAGS.keys.each do |tag|
		#	totalRep = totalRep + UTAGS[tag]
		#end

		#UTAGS.keys each do |tag|
		#	P[tag] = UTAGS[tag]/totalRep
		#end

		E = Hash.new

		#UTAGS.keys each do |tag|
		#	QTAGS.keys each do |qtag|
		#		E[tag] = getValueFromAdjacencyGraph(tag, qtag)
		#	end
		#end

		EP = Hash.new

		totalExpertRep = 0

		#UTAGS.keys.each do |tag|
		#	totalExpertRep = totalExpertRep + E[tag]
		#end

		#UTAGS.keys each do |tag|
		#	EP[tag] = E[tag]/totalExpertRep
		#end

		D = Hash.new
		#UTAGS.keys each do |tag|
		#	D[tag] = Math.abs(P[tag] - EP[tag])
		#end

		totalDifference = 0

		#UTAGS.keys.each do |tag|
		#	totalDifference = totalDifference + D[tag]
		#end

		dAverage = totalDifference / n

		endValue = 1 - dAverage

	end
	  
	def calculateScoreRatingCategories()
		#do nothing
		
	end
	
	def calculateDealBreakerCategory()
		if @questionIsClosedForAnswers == true
			if @questionIsClosedForAnswersUnderRepOf >= @currentUsersRep
				return 0
			end
		end
		return 1
	end
	
	def calculateEverythingCategory()
		#do nothing
	end

	def calculateValues(category)
		childrenValue = 0
		if category.children != nil
			category.children.each do |child|
				childrenValue = childrenValue + calculateValues(child)
			end
		end
		
		myValue = category.calculationFunction()
		myWeightedValue = category.calculateWeightedScore(myValue + childrenValue)
	end
	

	def initialize()

	#values needed for different functions
	@questionIsClosedForAnswers = false
	@questionIsClosedForAnswersUnderRepOf = 0

	@currentUsersRep = 100

	@allAnswersWithoutFlags = []

	#end values needed for different functions


	@recency = MagicBlackBoxCategory.new("recency", 0.15, 1, nil, method(:calculateRecency))
	@notAnswered = MagicBlackBoxCategory.new("notAnswered", 0.3, 1, nil, method(:calculateNotAnswered))
	@bountyAvailable = MagicBlackBoxCategory.new("bountyAvailable", 0.05, 1, nil, method(:calculateBountyAvailable))
	@questionQuality = MagicBlackBoxCategory.new("questionQuality", 0.25, 1, nil, method(:calculateQuestionQuality))
	@questionDifficulty = MagicBlackBoxCategory.new("questionDifficulty", 0.20, 1, nil, method(:calculateQuestionDifficulty))
	
	@questionRelevance = MagicBlackBoxCategory.new("questionRelevance", 0.5, 1, 
		[@recency, @notAnswered, @bountyAvailable,@questionQuality, @questionDifficulty], method(:calculateQuestionRelevance))
		
	@tagRelevance = MagicBlackBoxCategory.new("tagRelevance", 0.5, 1, nil, method(:calculateTagRelevance))

	@scoreRatingCategories = MagicBlackBoxCategory.new("scoreRatingCategories", 0.5, 1, 
		[@questionRelevance,@scoreRatingCategories], method(:calculateScoreRatingCategories))
		
	@dealBreakerCategory = MagicBlackBoxCategory.new("dealBreakerCategory", 0.5, 1, nil, method(:calculateDealBreakerCategory))

	@everythingCategory = MagicBlackBoxCategory.new("everythingCategory", 1, 1, 
		[@scoreRatingCategories, @dealBreakerCategory], method(:calculateEverythingCategory))
	end
    
	def runBlackBox()
	calculateValues(@everythingCategory)
	end
end



