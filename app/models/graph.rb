class Graph < ActiveRecord::Base
  validates :src_tag, presence: true, length: { maximum: 100 }
  validates :dest_tag, presence: true, length: { maximum: 100 }
  validates :upvotes, numericality: { greater_than_or_equal_to: 0 }

  def Graph.add_edge(src_tag, dest_tag, upvotes)
    edge = find_by(src_tag: src_tag, dest_tag: dest_tag)
    if edge
        edge.update(upvotes: edge.upvotes + upvotes)
    else
      create(src_tag: src_tag, dest_tag: dest_tag, upvotes: upvotes)
    end
  end

  def Graph.upvotes_for_src(src_tag)
    self.where("src_tag = ? and dest_tag != ?", src_tag, src_tag).order(upvotes: :desc)
  end

  def Graph.upvotes_for_tags(src_tag, dest_tag)
    self.where("src_tag = ? and dest_tag = ?", src_tag, dest_tag).first.upvotes
  end

end
