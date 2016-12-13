require_relative './MagicBlackBoxParameters.rb'
require 'set'
class MagicBlackBoxCategory
  attr_reader :name
  attr_reader :weight
  attr_reader :maxValue
  attr_reader :children
  attr_reader :calculationFunction

	def initialize(name, weight, maxValue, children, calculationFunction)
		@name = name
		@weight = weight
		@maxValue = maxValue
		@children = children
		@calculationFunction = calculationFunction
	end

	def calculateWeightedScore(value)
		normalizedValue = value.to_f / @maxValue
		totalWeighting = @weight

		weightedScore = value * totalWeighting
	end

end

class MagicBlackBox

	def calculateRecency()
		minTimeThreshold = 60
		highTimeThreshold = 60 * 20

		deltaTime = @currentTime - @question.creationTime

		if deltaTime < minTimeThreshold
			return 1
		elsif deltaTime >highTimeThreshold
			return 0 
		else
			return 1 - (deltaTime.to_f/highTimeThreshold)
		end
	end

  def calculateNotAnswered()

	  pointsThreshold = 25

		if @question.upvotesOfAnswersWithoutFlagsList.count == 0
			return 1
		end

		score = 0

		@question.upvotesOfAnswersWithoutFlagsList.each do |upvotes|

			if upvotes >= pointsThreshold
				score = score + 0.5
			elsif upvotes >= Math.sqrt(pointsThreshold)
				score = score + 0.5 * (upvotes.to_f/pointsThreshold)
			else
				score = score + 0.1 * (upvotes.to_f/pointsThreshold)
			end
		end

		endValue = 1 - score
		if endValue < 0
			endValue = 0
		end

		return endValue
	end

	def calculateBountyAvailable()
		if @question.bountyAvailable == true
			return 1
		end

		return 0
	end

	def calculateQuestionQuality()
		flagThreshold = 3
		repThreshold = 10

		flagWeight = 0.5
		repWeight = 0.5

		if @question.numberOfFlags == 0 && @question.questionUpvotes >=repThreshold
			return 1
		end

		if @question.numberOfFlags >= flagThreshold || @question.questionUpvotes <0
			return 0
		end

		flagScore = flagWeight* @question.numberOfFlags.to_f/flagThreshold
		repScore = repWeight* (repThreshold - @question.questionUpvotes).to_f/repThreshold

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
		@question.upvotesOfAnswersWithoutFlagsList.each do |upvotes|
			if upvotes >= pointThreshold
				answerExistsAboveThreshold = true
			end
		end

		if answerExistsAboveThreshold == false
			if @question.pageViews >= pageViewThreshold
				answerPointScore = 1
			else
				answerPointScore = 0.5
			end
		else
			if currentQuestion.pageViews >= pageViewThreshold
				answerPointScore = 0.5
			else
				answerPointScore = 0
			end
		end

		if @user.reputation >= @question.questionCreatorReputation * 100
			repScore = 0
		elsif @user.reputation >= @question.questionCreatorReputation * 10
			repScore = 0.25
		elsif @user.reputation >= @question.questionCreatorReputation
			repScore = 0.50
		elsif @user.reputation * 10 >= @question.questionCreatorReputation
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
		return 0
	end

	def getValueFromAdjacencyGraph(tag, qtag)

		#todo: actually get value from graph
		return 9
	end

	def calculateTagRelevance()
		n = @user.tagReputationHash.length
		@@UTAGS = @user.tagReputationHash
		@@QTAGS  = @question.tagsSet

		totalRep = 0
		@@UTAGS.each do |tag, rep|
			totalRep = totalRep + rep
		end
		@@UTAGSProportion = Hash.new
		@@UTAGS.each do |tag, rep|
			@@UTAGSProportion[tag] = rep.to_f/totalRep
		end

		totalExpertRep = 0
		@adjacencyData.adjacencyGraphData.each do |tag, value|
			totalExpertRep = totalExpertRep + value
		end

		adjacencyDataProportion = Hash.new
		@adjacencyData.adjacencyGraphData.each do |tag, value|
			adjacencyDataProportion[tag] = value.to_f/totalExpertRep
		end

		differenceHash = Hash.new
		@@UTAGS.keys.each do |tag|
			differenceHash[tag] = (@@UTAGSProportion[tag] - adjacencyDataProportion[tag]).abs
		end

		totalDifference = 0

		differenceHash.each do |tag, value|
			totalDifference = totalDifference + value
		end

		dAverage = totalDifference.to_f / n

		endValue = 1 - dAverage
	end

	def calculateScoreRatingCategories()
		#do nothing
		return 0
	end

	def calculateDealBreakerCategory()
		if @question.questionIsClosedForAnswers == true
			 return 0
		end
		return 1
	end

	def calculateEverythingCategory()
		#do nothing
		return 0
	end

	def calculateValues(category)
		childrenValue = 0
		if category.children != nil
			category.children.each do |child|
				puts "--------------" + child.name
				childValue = calculateValues(child)
				if childValue.to_f.nan?
					childValue = 0.0
				end
				childrenValue = childrenValue + childValue
			end
		end

		myValue = category.calculationFunction.call()
		if myValue.to_f.nan?
			myValue = 0
		end
		comboValue = myValue + childrenValue
		puts "comboValue #{comboValue}"

		myWeightedValue = category.calculateWeightedScore(comboValue)
		puts "myWeightedValue #{myWeightedValue}"
		return myWeightedValue
	end


	def initialize(magicBlackBoxParameters)

		@user = magicBlackBoxParameters.currentUser
		@question = magicBlackBoxParameters.currentQuestion
		@adjacencyData = magicBlackBoxParameters.adjacencyGraphData
    #puts @adjacencyData.inspect
		@currentTime = magicBlackBoxParameters.currentTime

		@recency = MagicBlackBoxCategory.new("recency", 0.2, 1, nil, method(:calculateRecency))
		@notAnswered = MagicBlackBoxCategory.new("notAnswered", 0.3, 1, nil, method(:calculateNotAnswered))
		@bountyAvailable = MagicBlackBoxCategory.new("bountyAvailable", 0.05, 1, nil, method(:calculateBountyAvailable))
		@questionQuality = MagicBlackBoxCategory.new("questionQuality", 0.25, 1, nil, method(:calculateQuestionQuality))
		@questionDifficulty = MagicBlackBoxCategory.new("questionDifficulty", 0.20, 1, nil, method(:calculateQuestionDifficulty))

		@questionRelevance = MagicBlackBoxCategory.new("questionRelevance", 0.3, 1,
			[@recency, @notAnswered, @bountyAvailable,@questionQuality, @questionDifficulty], method(:calculateQuestionRelevance))

		@tagRelevance = MagicBlackBoxCategory.new("tagRelevance", 0.7, 1, nil, method(:calculateTagRelevance))

		@scoreRatingCategories = MagicBlackBoxCategory.new("scoreRatingCategories", 0.5, 1,
			[@questionRelevance,@tagRelevance], method(:calculateScoreRatingCategories))

		@dealBreakerCategory = MagicBlackBoxCategory.new("dealBreakerCategory", 0.5, 1, nil, method(:calculateDealBreakerCategory))

		@everythingCategory = MagicBlackBoxCategory.new("everythingCategory", 1, 1,
			[@scoreRatingCategories, @dealBreakerCategory], method(:calculateEverythingCategory))
    end

	def runBlackBox()
	   calculateValues(@everythingCategory)
	end
end

    question = MagicBlackBoxCurrentQuestion.new(['swift3', 'facebook-login', 'xcode8', 'ios10'].to_set, [], 1481650896, false, 0, 0, 3, 1505, false, 41127357)
    cu = MagicBlackBoxCurrentUser.new({'swift3' => 35, 'ios10' => 2, "c#" => 6}, 300)
    #ken info {'mongodb', 'projection', 'java', 'javascript', 'jquery', 'python', 'tree', 'android', 'if-statement', 'c++', 'list', 'c++builder'},
    currentTime = Time.now.to_i
    params = MagicBlackBoxParameters.new(cu, question, MagicBlackBoxAdjacencyGraphData.new(cu, question), currentTime)
    puts MagicBlackBox.new(params).runBlackBox()

# class MagicBlackBoxRunner
# 	def initialize(currentUser, questionList, adjacencyGraphData)
# 		@currentUser = currentUser
# 		@questionList = questionList
# 		@adjacencyGraphData = adjacencyGraphData
# 	end
# 	def run()
# 	  currentTime = Time.now.to_i
# 	  questionList = Hash.new
# 	  @questionList.each do |question|
# 	  	magicBlackBoxParameters = MagicBlackBoxParameters.new(@currentUser, question, @adjacencyGraphData, currentTime)
# 		questionList[question.questionId] = MagicBlackBox.new(magicBlackBoxParameters).runBlackBox()
# 	  end
# 		questionList.sort_by {|question,score| [-score]}
# 	end
# end

#sampleData

# tagReputationHash = Hash.new
# tagReputationHash["C#"] = 40
# tagReputationHash["Java"] = 10
# tagReputationHash["PHP"] = 3

# userReputation = 100
# currentUser123 = MagicBlackBoxCurrentUser.new(tagReputationHash, userReputation)

# questionTagsSet = ["C#", "Java"]
# questionUpvotesOfAnswersWithoutFlagsList = []
# questionCreationTime = Time.now.to_i - 30
# questionBountyAvailable = true
# questionNumberOfFlags = 0
# questionUpvotes = 5
# questionPageViews = 75
# questionCreatorReputation = 15
# questionIsClosedForAnswers = false
# questionId = 23
# currentQuestion = MagicBlackBoxCurrentQuestion.new(questionTagsSet,
# 				questionUpvotesOfAnswersWithoutFlagsList, questionCreationTime,
# 				questionBountyAvailable, questionNumberOfFlags, questionUpvotes,
# 				questionPageViews, questionCreatorReputation, questionIsClosedForAnswers, questionId)


# questionTagsSet2 = ["C#", "Java"]
# questionUpvotesOfAnswersWithoutFlagsList2 = []
# questionCreationTime2 = Time.now.to_i - 30
# questionBountyAvailable2 = false
# questionNumberOfFlags2 = 1
# questionUpvotes2 = 5
# questionPageViews2 = 750
# questionCreatorReputation2 = 15
# questionIsClosedForAnswers2 = false
# questionId2 = 20

# currentQuestion2 = MagicBlackBoxCurrentQuestion.new(questionTagsSet2,
# 				questionUpvotesOfAnswersWithoutFlagsList2, questionCreationTime2,
# 				questionBountyAvailable2, questionNumberOfFlags2, questionUpvotes2,
# 				questionPageViews2, questionCreatorReputation2, questionIsClosedForAnswers2, questionId2)

# questions = [currentQuestion,currentQuestion2]

# graphData = Hash.new
# graphData["C#"] = 4000
# graphData["Java"] = 1000
# graphData["PHP"] = 200

# currentTime = Time.now.to_i

# blackBoxRunner = MagicBlackBoxRunner.new(currentUser123, questions, graphData)

# # magicBlackBoxParameters = MagicBlackBoxParameters.new(currentUser, currentQuestion, graphData, currentTime)
# # blackBox = MagicBlackBox.new(magicBlackBoxParameters)

# puts blackBoxRunner.run()
