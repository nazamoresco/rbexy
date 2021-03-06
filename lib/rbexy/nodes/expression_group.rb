module Rbexy
  module Nodes
    class ExpressionGroup < AbstractNode
      using Rbexy::Refinements::Array::MapTypeWhenNeighboringType
      using Rbexy::Refinements::Array::InsertBetweenTypes

      attr_reader :statements, :outer_template, :inner_template

      OUTPUT_UNSAFE = "@output_buffer.concat(Rbexy::Runtime.expr_out(%s));"
      OUTPUT_SAFE = "@output_buffer.safe_concat(Rbexy::Runtime.expr_out(%s));"
      SUB_EXPR = "%s"
      SUB_EXPR_OUT = "Rbexy::Runtime.expr_out(%s)"

      def initialize(statements, outer_template: OUTPUT_UNSAFE, inner_template: "%s")
        @statements = statements
        @outer_template = outer_template
        @inner_template = inner_template
      end

      def precompile
        [ExpressionGroup.new(precompile_statements, outer_template: outer_template, inner_template: inner_template)]
      end

      def compile
        outer_template % (inner_template % statements.map(&:compile).join)
      end

      private

      def precompile_statements
        precompiled = compact(statements.map(&:precompile).flatten)

        transformed = precompiled.map do |node|
          case node
          when Raw
            Raw.new(node.content, template: Raw::EXPR_STRING)
          when ComponentElement
            ComponentElement.new(node.name, node.members, node.children, template: ComponentElement::EXPR_STRING)
          when ExpressionGroup
            ExpressionGroup.new(node.statements, outer_template: SUB_EXPR, inner_template: node.inner_template)
          else
            node
          end
        end.map_type_when_neighboring_type(ExpressionGroup, Raw) do |node|
          ExpressionGroup.new(node.statements, outer_template: SUB_EXPR_OUT, inner_template: node.inner_template)
        end.insert_between_types(ExpressionGroup, Raw) do
          Expression.new("+")
        end.insert_between_types(ComponentElement, Raw) do
          Expression.new("+")
        end
      end
    end
  end
end
