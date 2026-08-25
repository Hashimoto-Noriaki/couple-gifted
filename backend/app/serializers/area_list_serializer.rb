class AreaListSerializer
  def initialize(areas)
    @areas = areas
  end

  def as_json(*)
    { areas: areas.map { |area| AreaSerializer.new(area).as_json } }
  end

  private

  attr_reader :areas
end
