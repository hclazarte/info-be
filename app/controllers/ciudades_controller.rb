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
      # Usar caché si no hay filtros
      ciudades = Rails.cache.fetch('ciudades_filtradas_total>10', expires_in: 24.hours) do
        Ciudad.order(:ciudad).where('total > 10').to_a
      end
    else
      # Búsqueda normal con filtros
      ciudades = Ciudad.order(:ciudad).where('total > 10')
      ciudades = ciudades.where('LOWER(ciudad) LIKE ?', "%#{params[:ciudad].downcase}%") if params[:ciudad].present?
      ciudades = ciudades.where('LOWER(pais) LIKE ?', "%#{params[:pais].downcase}%") if params[:pais].present?
    end

    if ciudades.any?
      render json: ciudades, status: :ok
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
