module Spree
  module Stock
    InventoryUnitBuilder.class_eval do
      # Overriden from Spree core to build inventory_units for each assembly part.
      # Use flatten at the end instead of flat_map, because the arrays nest
      # several layers deep.

      def units
        @order.line_items.map do |line_item|
          line_item.quantity.times.map do |i|
            if line_item.product.assembly?
              # Custom behavior
              line_item.assemblies_parts.map do |assembly|
                assembly.count.times.map do |x|
                  @order.inventory_units.build(
                    pending: true,
                    variant: assembly.part,
                    line_item: line_item
                  )
                end
              end
            else
              # Default behavior
              @order.inventory_units.build(
                pending: true,
                variant: line_item.variant,
                line_item: line_item
              )
            end
          end
        end.flatten
      end

    end
  end
end
