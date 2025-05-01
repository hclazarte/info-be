require 'faraday'

class CiudadesController < ApplicationController
  # GET /ciudades/:id
  def show
    ciudad = Ciudad.find_by(id: params[:id])

    if ciudad
      render json: ciudad, status: :ok
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end

  # GET /ciudades
  def index
    if params[:ciudad].blank? && params[:pais].blank?
      ciudades = Rails.cache.fetch('ciudades_priorizadas', expires_in: 24.hours) do
        grupo_a = Ciudad.where('total > 1000').order(:ciudad).pluck(:id, :ciudad)
        grupo_b = Ciudad.where('total <= 1000 AND total > 10').order(:ciudad).pluck(:id, :ciudad)
  
        (grupo_a + grupo_b).map { |id, nombre| { id: id, ciudad: nombre } }
      end
    else
      ciudades = Ciudad.order(:ciudad).where('total > 10')
      ciudades = ciudades.where('LOWER(ciudad) LIKE ?', "%#{params[:ciudad].downcase}%") if params[:ciudad].present?
      ciudades = ciudades.where('LOWER(pais) LIKE ?', "%#{params[:pais].downcase}%") if params[:pais].present?
      ciudades = ciudades.as_json(only: [:id, :ciudad])
    end  

    if ciudades.any?
      render json: ciudades.as_json(only: [:id, :ciudad]), status: :ok
    else
      render json: { error: 'No hay ciudades disponibles' }, status: :no_content
    end
  end

  # GET /ciudades/:id/zonas
  def zonas_por_ciudad
    ciudad = Ciudad.find_by(id: params[:id])

    if ciudad
      # Obtener el parámetro de descripción
      descripcion = params[:descripcion]&.strip

      # Filtrar las zonas por ciudad y descripción si corresponde
      zonas = Zona.where(ciudad_id: ciudad.id).where('"ZONAS"."TOTAL" > 10')
      zonas = zonas.where('LOWER(descripcion) LIKE ?', "%#{descripcion.downcase}%") if descripcion.present?

      # Ordenar las zonas alfabéticamente por descripción
      zonas = zonas.order('LOWER(descripcion)')

      render json: zonas, status: :ok
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end
end
