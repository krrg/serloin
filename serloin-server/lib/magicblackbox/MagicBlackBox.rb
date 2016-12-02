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
		#currentParent = @parent
		#while currentParent != nil do
		#	totalWeighting = totalWeighting *currentParent.weight
		#	currentParent = currentParent.parent
		#end
		
		weightedScore = value * totalWeighting
	end
	
	def calculateScoreRatingCategories()
	
	end
end


class MagicBlackBox

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

	def initialize()

	end
    def calculateRecency()
		
		
	end
  	def calculateNotAnswered()
		
		
	end
	
	def calculateBountyAvailable()
		
		
	end
	
	def calculateQuestionQuality()
		
		
	end
	
  	def calculateQuestionDifficulty()
		
		
	end
	
	def calculateQuestionRelevance()
		
		
	end
	
	def calculateTagRelevance()
		
		
	end
	  
	def calculateScoreRatingCategories()
		
		
	end
	
	def calculateDealBreakerCategory()
		
		
	end
	
	def calculateEverythingCategory()
		
		
	end
	
	
	calculateValues(@everythingCategory)
end



