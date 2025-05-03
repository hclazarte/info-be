# frozen_string_literal: true

class CiudadesCacheService
  CACHE_KEY = 'ciudades_priorizadas'
  TTL       = 24.hours

  # Devuelve un array de hashes: [{ id: 1, ciudad: 'La Paz' }, ...]
  def self.priorizadas
    Rails.cache.fetch(CACHE_KEY, expires_in: TTL) do
      grupo_a = Ciudad.where('total > 1000').order(:ciudad).pluck(:id, :ciudad)
      grupo_b = Ciudad.where('total <= 1000 AND total > 10').order(:ciudad).pluck(:id, :ciudad)

      (grupo_a + grupo_b).map { |id, nombre| { id: id, ciudad: nombre } }
    end
  end
end
