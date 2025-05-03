class InicioController < ApplicationController
  def objetos
    path = params[:path].to_s

    ciudad_ini = { id: '' }
    zona_ini = { id: '' }
    zonas_ini = []
    text_ini = ''

    if path.strip != '' && path.strip != '/' && path.downcase.strip != '/bolivia'

      partes = recuperar_partes(path)
      partes.each_with_index do |parte,i| 
        resultado = Ciudad.where('LOWER(CIUDAD) = ?',  parte.tr('-', ' '))
        if resultado.any?
          ciudad_ini = resultado[0]
          partes.delete_at(i)
          break 
        end
      end

      if ciudad_ini != { id: '' }
        zonas_ini = Zona.where('ciudad_id = ?', ciudad_ini.id)
        partes.each_with_index do |parte,i| 
          resultado = zonas_ini.where('LOWER(DESCRIPCION) LIKE ?', parte.tr('-', ' '))
          if resultado.any?
            zona_ini = resultado[0]
            partes.delete_at(i)
            break 
          end
        end
      end
      
      partes = partes.map { |p| p.strip.downcase }
      text_ini = partes.join(' ')

    else
      if path.strip == '' || path.strip == '/'
        Rails.logger.info("Tu mensaje aquí")
        ciudad_ini = CiudadDetectadaPorIp.buscar(request.remote_ip) || Ciudad.find_by('UPPER(ciudad) LIKE ?', '%LA PAZ%')
        zonas_ini = Zona.where('ciudad_id = ?', ciudad_ini.id)
      end
    end
    ciudades_ini = CiudadesCacheService.priorizadas

    render json: {
      ciudades_ini: ciudades_ini, 
      ciudad_ini: ciudad_ini,
      zonas_ini: zonas_ini,
      zona_ini: zona_ini,
      text_ini: text_ini
    }
  end
  

  private

  def recuperar_partes(path)
    partes = path.downcase
              .split('/')
              .reject(&:blank?)
              .reject { |p| p == 'bolivia' }
  end
end
