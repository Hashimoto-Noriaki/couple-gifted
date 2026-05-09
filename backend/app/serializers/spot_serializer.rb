class SpotSerializer
  include JSONAPI::Serializer

  attributes :name, :address, :google_place_id
end
