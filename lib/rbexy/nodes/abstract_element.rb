module Rbexy
  module Nodes
    class AbstractElement < AbstractNode
      attr_reader :name, :members, :children

      def initialize(name, members, children)
        @name = name
        @members = members || []
        @children = children
      end
    end
  end
end
