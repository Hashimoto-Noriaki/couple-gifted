class SpotSerializer
  def initialize(spot)
    @spot = spot
  end

  def as_json(*)
    {
      id: spot.id,
      name: spot.name,
      area_id: spot.area_id,
      category_id: spot.category_id,
      average_rating: spot.rating_average&.to_f,
      reviews_count: spot.reviews_count
    }
  end

  private

  attr_reader :spot
end
