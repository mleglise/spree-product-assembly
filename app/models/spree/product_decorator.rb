Spree::Product.class_eval do
  scope :individual_saled, -> { where(individual_sale: true) }

  scope :search_can_be_part, ->(query){ not_deleted.available.joins(:master)
    .where(arel_table["name"].matches("%#{query}%").or(Spree::Variant.arel_table["sku"].matches("%#{query}%")))
    .where(can_be_part: true)
    .limit(30)
  }

  validate :assembly_cannot_be_part, :if => :assembly?

  delegate :parts, :assemblies_part, :add_part, :remove_part, :set_part_count, to: :master

  def assembly?
    variants_including_master.any? &:assembly?
  end

  def assembly_cannot_be_part
    errors.add(:can_be_part, Spree.t(:assembly_cannot_be_part)) if can_be_part
  end

  private
  def assemblies_part(variant)
    Spree::AssembliesPart.get(self.id, variant.id)
  end
end
