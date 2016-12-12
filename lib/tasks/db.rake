namespace :db do

  desc "Load graph edge data from the given CSV file"
  task :load_edges, [:file] => :environment do |t, args|
    args.with_defaults(:file => "edge_entries.csv")
    file_path = "./data/#{args.file}"
    puts "\n**** Loading data from #{file_path} ****\n\n"
    file = File.open(file_path)
    count = 1
    Graph.transaction do
      file.each do |line|
        data = line.split(",")
        Graph.add_edge(data[0], data[1], Integer(data[2]))
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
