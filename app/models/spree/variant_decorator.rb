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

  def assemblies_for(variants)
    ids = variants.map do |v|
      v.class.name == 'Spree::Product' ? v.master.id : v.id
    end

    assemblies.where(id: ids)
  end

  def part?
    assemblies.exists?
  end

  def assembly_part(variant)
    Spree::AssembliesPart.get(self.id, variant.id)
  end

  def parts_min_total_on_hand
    min = self.parts.map do |part|
      count = part.total_on_hand / assembly_part(part).count
    end.min

    min ? min : 0
  end

  # variant parts plus product parts
  def all_parts
    if is_master?
      parts
    else
      parts + product.parts
    end
  end
end
