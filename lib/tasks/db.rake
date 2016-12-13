require './lib/magicblackbox/MagicBlackBoxParameters'
require './lib/magicblackbox/MagicBlackBox'

namespace :db do

  desc "Load graph edge data from the given CSV file"
  task :load_edges, [:file] => :environment do |t, args|
    args.with_defaults(:file => "edge_entries.csv")
    file_path = "./data/#{args.file}"
    puts "\n**** Loading data from #{file_path} ****\n\n"
    file = File.open(file_path)
    hash = Hash.new
    file.each do |line|
      data = line.split(",")
      key = data[0] + ',' + data[1]
      if !hash.key?(key)
          hash[key] = 0
      end
      hash[key] = hash[key] + Integer(data[2])
    end
    count = 1
    Graph.transaction do
      hash.each do |key, value|
        key_parts = key.split(',')
        Graph.add_edge(key_parts[0], key_parts[1], Integer(value))
        count = count + 1
        if count % 10000 == 0
          puts "#{count} records loaded"
        end
      end
    end
  end

  desc "Delete all edges from the graph. This essentially deletes the graph."
  task delete_edges: :environment do
    Graph.delete_all
  end


  task magic_box: :environment do
    question = MagicBlackBoxCurrentQuestion.new(['java', 'facebook-login', 'xcode8', 'ios10'].to_set, [], 1481650896, false, 0, 0, 3, 1505, false, 41127357)
    cu = MagicBlackBoxCurrentUser.new({"mongodb"=>77, "projection"=>75, "java"=>60, "javascript"=>18, "jquery"=>13, "post"=>7, "python"=>22, "tree"=>6, "android"=>6, "performance"=>4, "if-statement"=>4, "c++"=>10, "list"=>4,
      "c++builder"=>4, "c++builder-2009"=>4, "swing"=>4, "hashmap"=>4, "python-module"=>4, "pyopenssl"=>4, "php"=>3, "regex"=>3, "preg-split"=>3, "object"=>3, "point"=>3, "hibernate"=>3, "hashcode"=>2, "math"=>2,
      "floating-point"=>2, "ieee"=>2, "static"=>2, "arrays"=>6, "nested"=>2, "elements"=>2, "linux"=>2, "assembly"=>2, "operating-system"=>2, "virtualbox"=>2, "bootloader"=>2, "loops"=>2, "eclipse"=>3, "design-patterns"=>2,
      "syntax"=>2, "json"=>2, "html"=>2, "python-3.x"=>2, "arraylist"=>1, "load"=>1, "iphone"=>1, "nsstring"=>1, "uitextfield"=>1, "pointers"=>1, "dereference"=>1, "string"=>1, "substring"=>1, "joptionpane"=>1,
      "class"=>1, "nullpointerexception"=>1, "dictionary"=>1, "multidimensional-array"=>1, "linked-list"=>1, "user-interface"=>1, "fonts"=>1, "intellij-idea"=>1, "render"=>1, "apache-httpclient-4.x"=>1, "apache-commons-httpclient"=>1,
      "file"=>1, "stack"=>1, "linkedhashmap"=>1, "multikey"=>1, "query-performance"=>1, "variables"=>1, "for-loop"=>1, "java.util.scanner"=>1, "twitter-bootstrap"=>1, "inheritance"=>1, "subtyping"=>1, "python-2.7"=>1, "python-internals"=>1, "multithreading"=>1,
      "runnable"=>1}, 2795)
    #ken info {'mongodb', 'projection', 'java', 'javascript', 'jquery', 'python', 'tree', 'android', 'if-statement', 'c++', 'list', 'c++builder'},
    currentTime = Time.now.to_i
    params = MagicBlackBoxParameters.new(cu, question, MagicBlackBoxAdjacencyGraphData.new(cu, question), currentTime)
    puts MagicBlackBox.new(params).runBlackBox()
  end
end
