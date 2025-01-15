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
    ipinfodb_key = '20b33a1e56e6b765d318228c9e3ef34022692b9cff4ae0c46edfe6da6d6a4175'
    ipinfodb_url = "http://api.ipinfodb.com/v3/ip-city/?key=#{ipinfodb_key}&ip=#{remote_ip}"

    ciudad = nil

    # Excluir IP locales específicas
    unless remote_ip == '190.181.25.130' || remote_ip.start_with?('192.168.0')
      begin
        response = Net::HTTP.get(URI(ipinfodb_url))
        ip_info = response.split(';')

        # `ip_info[5]` es el campo de la ciudad según el API de ipinfodb
        if ip_info[5].present?
          ciudad_nombre = ip_info[5].upcase
          ciudad = Ciudad.where("UPPER(ciudad) LIKE ?", "%#{ciudad_nombre}%").first
        end
      rescue => e
        Rails.logger.error "Error fetching IP info: #{e.message}"
      end
    end

    # Si no se encontró ciudad, retornar la ciudad predeterminada
    ciudad ||= Ciudad.by_name('La Paz')

    if ciudad
      render json: ciudad
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end
  # GET /ciudades
  def index
    ciudades = Ciudad.all

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
      zonas = Zona.where(ciudad_id: ciudad.id)

      if zonas.any?
        render json: zonas, status: :ok
      else
        render json: { error: 'No hay zonas disponibles para esta ciudad' }, status: :no_content
      end
    else
      render json: { error: 'Ciudad no encontrada' }, status: :not_found
    end
  end
end
