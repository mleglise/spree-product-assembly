Spree::Variant.class_eval do
  has_and_belongs_to_many  :assemblies, :class_name => "Spree::Variant",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "part_id", :association_foreign_key => "assembly_id"

  has_and_belongs_to_many  :parts, :class_name => "Spree::Variant",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "assembly_id", :association_foreign_key => "part_id"

  has_many :assemblies_parts, :class_name => "Spree::AssembliesPart",
    :foreign_key => "assembly_id"

  def add_part(variant, count = 1)
    set_part_count(variant, count_of(variant) + count)
  end

  def remove_part(variant)
    set_part_count(variant, 0)
  end

  def set_part_count(variant, count)
    ap = assemblies_part(variant)
    if count > 0
      ap.count = count
      ap.save
    else
      ap.destroy
    end
    reload
  end

  def count_of(variant)
    ap = assemblies_part(variant)
    # This checks persisted because the default count is 1
    ap.persisted? ? ap.count : 0
  end

  def assembly?
    parts.present?
  end

  def assemblies_for(products)
    assemblies.where(id: products)
  end

  def part?
    assemblies.exists?
  end
end
