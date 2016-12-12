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

end
