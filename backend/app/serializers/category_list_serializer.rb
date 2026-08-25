class CategoryListSerializer
  def initialize(categories)
    @categories = categories
  end

  def as_json(*)
    { categories: categories.map { |category| CategorySerializer.new(category).as_json } }
  end

  private

  attr_reader :categories
end
