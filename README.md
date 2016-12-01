# SERLOIN
SERLOIN - StackExchange Recommendation Layer of Intelligent Nepotism

## DB Rake Tasks

**db:load_edges**
Loads a CSV edge file into the graph. The CSV file must reside in the data folder. This task reads in a file called "edge_entries.csv" by default. To load a different file, use the following command: *rake "db:load_edges[filename]"*

With about 500,000 edges, this task will take about 7 minutes to execute.

**db:delete_edges**
This task deletes all edges in the Graph relation. Essentially, it destroys the graph. 
