require 'test_helper'
require './lib/magicblackbox/MagicBlackBoxParameters'
require './lib/magicblackbox/MagicBlackBox'
class SessionControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Magic Black Box" do
    question = MagicBlackBoxCurrentQuestion.new(['java', 'facebook-login', 'xcode8', 'ios10'].to_set, [], 1481650896, false, 0, 0, 3, 1505, false, 41127357)
    cu = MagicBlackBoxCurrentUser.new({'swift3' => 35, 'ios10' => 2, "c#" => 6}, 300)
    #ken info {'mongodb', 'projection', 'java', 'javascript', 'jquery', 'python', 'tree', 'android', 'if-statement', 'c++', 'list', 'c++builder'},
    currentTime = Time.now.to_i
    params = MagicBlackBoxParameters.new(cu, question, MagicBlackBoxAdjacencyGraphData.new(cu, question), currentTime)
    puts MagicBlackBox.new(params).runBlackBox()
  end

end
