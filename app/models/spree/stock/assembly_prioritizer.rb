module Spree
  module Stock
    # Responsible for keeping packages consistent with items in the order 
    #
    # It loops through the packages received and pick up only what the
    # order actually needs. Irrevelant packages items have their items quantity
    # set to zero and are pruned so that only relevant packages are returned
    #
    # e.g. Customer order 1 Stein. Spree generates one package for each stock
    # location on the system and passes the following ones to the Prioritizer
    #
    #   [#<Spree::Order:0xb378e098> - Stein 1 backordered,
    #    #<Spree::Order:0xb378e098> - Stein 1 on_hand,
    #    #<Spree::Order:0xb378e098> - Stein 1 backordered]
    #
    # Then the prioritizer searches for the first on_hand package item present
    # and prunes the others:
    #
    #   [#<Spree::Order:0xb378e098> - Stein 1 on_hand]
    # 
    # In case packages don't have any on_hand items the first backordered is
    # kept and the others pruned before returning
    class AssemblyPrioritizer < Prioritizer
      attr_reader :packages, :order

      private
        def adjust_packages
          order.line_items.each do |line_item|
            product = line_item.product

            if product.assembly?
              line_item.variant_plus_master.each do |variant|
                variant.parts.each do |part|
                  update_packages_quantity(part, line_item, part_quantity_required(variant, line_item, part))
                end
              end
            else
              update_packages_quantity(line_item.variant, line_item, line_item.quantity)
            end
          end
        end

        def part_quantity_required(variant, line_item, part)
          variant.count_of(part) * line_item.quantity
        end

        def update_packages_quantity(variant, line_item, quantity)
          package_adjuster = @adjuster_class.new(variant, quantity, :on_hand)
          visit_packages(package_adjuster, line_item)

          package_adjuster.status = :backordered
          visit_packages(package_adjuster, line_item)
        end

        def visit_packages(package_adjuster, line_item)
          packages.each do |package|
            item = package.find_item package_adjuster.variant, package_adjuster.status, line_item
            package_adjuster.adjust(item) if item
          end
        end
    end
  end
end
