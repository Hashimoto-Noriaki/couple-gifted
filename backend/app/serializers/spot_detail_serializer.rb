class SpotDetailSerializer < SpotSerializer
  def initialize(spot, saved:)
    super(spot)
    @saved = saved
  end

  def as_json(*)
    super.merge(saved: saved, address: spot.address)
  end

  private

  attr_reader :saved
end
