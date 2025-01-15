Rails.application.routes.draw do
  get 'comercios/search'
  get 'zonas/active'
  get 'ciudades/show'
  get 'ciudades/by_client_ip'
  get 'ciudades/index'
  # RecuperaCiudadesQue - Devuelve la ciudad por ID
  get 'ciudades/:id', to: 'ciudades#show', as: 'recupera_ciudad'

  # RecuperaCiudadClientIP - Devuelve la ciudad correspondiente al IP del cliente
  get 'ciudades/client_ip', to: 'ciudades#by_client_ip', as: 'recupera_ciudad_client_ip'

  # RecuperaTodosCiudades - Devuelve todas las ciudades
  get 'ciudades', to: 'ciudades#index', as: 'recupera_todas_ciudades'

  # Devuelve las zonas por ciudad
  get 'ciudades/:id/zonas', to: 'ciudades#zonas_por_ciudad', as: 'zonas_por_ciudad'

  # BuscaComercios - Busca comercios por texto
  get 'comercios/buscar', to: 'comercios#search', as: 'busca_comercios'

  # Contar Búsqueda
  get 'comercios/contar', to: 'comercios#contar', as: 'contar_comercios'

  # Devuelve Comercios
  get 'comercios/lista', to: 'comercios#lista', as: 'lista_comercios'
end
