class SpotListSerializer
  def initialize(spots, next_cursor:)
    @spots = spots
    @next_cursor = next_cursor
  end

  def as_json(*)
    {
      spots: spots.map { |spot| SpotSerializer.new(spot).as_json },
      next_cursor: next_cursor
    }
  end

  private

  attr_reader :spots, :next_cursor
end
