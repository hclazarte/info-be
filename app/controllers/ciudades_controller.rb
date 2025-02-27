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

  def by_client_ip
    remote_ip = request.remote_ip
    Rails.logger.info("Remote IP=#{remote_ip}")
    ipinfodb_key = ENV['IPINFODB_KEY'] || 'default_fallback_key'
    ipinfodb_url = "http://api.ipinfodb.com/v3/ip-city/?key=#{ipinfodb_key}&ip=#{remote_ip}"
  
    ciudad = nil
  
    # Excluir IP locales específicas
    unless (remote_ip.include?('190.181.25.130') || 
           remote_ip.start_with?('192.168.0') || 
           remote_ip.include?('127.0.0.1') ||
           remote_ip.include?('::1'))
      begin
        response = Faraday.get(ipinfodb_url)
        
        if response.status == 200
          ip_info = response.body.split(';')
  
          if ip_info[5].present?
            ciudad_nombre = ip_info[5].upcase
            ciudad = Ciudad.where("UPPER(ciudad) LIKE ?", "%#{ciudad_nombre}%").first
          end
        else
          Rails.logger.error "Error en la respuesta: #{response.status}"
        end
  
      rescue Faraday::Error => e
        Rails.logger.error "Error fetching IP info: #{e.message}"
      end
    end
  
    ciudad ||= Ciudad.by_name('La Paz')
  
    if ciudad
      render json: ciudad
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end  
  # GET /ciudades
  def index
    # Filtrar por ciudad y país si se proporcionan en los parámetros
    ciudades = Ciudad.order(:ciudad).where("total > 10")

    if params[:ciudad].present?
      ciudades = ciudades.where('LOWER(ciudad) LIKE ?', "%#{params[:ciudad].downcase}%")
    end

    if params[:pais].present?
      ciudades = ciudades.where('LOWER(pais) LIKE ?', "%#{params[:pais].downcase}%")
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
      zonas = Zona.where(ciudad_id: ciudad.id).where("\"ZONAS\".\"TOTAL\" > 10")
      if descripcion.present?
        zonas = zonas.where("LOWER(descripcion) LIKE ?", "%#{descripcion.downcase}%")
      end

      # Ordenar las zonas alfabéticamente por descripción
      zonas = zonas.order("LOWER(descripcion)")

      render json: zonas, status: :ok
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end
end
