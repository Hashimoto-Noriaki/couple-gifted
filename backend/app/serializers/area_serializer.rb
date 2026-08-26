class AreaSerializer
  def initialize(area)
    @area = area
  end

  def as_json(*)
    {
      id: area.id,
      name: area.name,
      parent_id: area.parent_id,
      position: area.position
    }
  end

  private

  attr_reader :area
end
