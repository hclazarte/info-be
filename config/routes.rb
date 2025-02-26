Rails.application.routes.draw do
  scope '/api' do
    # Ciudades
    get 'ciudades/by_client_ip', to: 'ciudades#by_client_ip', as: 'recupera_ciudad_client_ip'
    get 'ciudades/:id', to: 'ciudades#show', as: 'recupera_ciudad'
    get 'ciudades', to: 'ciudades#index', as: 'recupera_todas_ciudades'
    get 'ciudades/:id/zonas', to: 'ciudades#zonas_por_ciudad', as: 'zonas_por_ciudad'

    # Comercios
    get 'comercios/search', to: 'comercios#search', as: 'busca_comercios'
    get 'comercios/contar', to: 'comercios#contar', as: 'contar_comercios'
    get 'comercios/lista', to: 'comercios#lista', as: 'lista_comercios'

    # Zonas
    get 'zonas/active', to: 'zonas#active', as: 'zonas_activas'

    # Correos
    post 'correos', to: 'correos#create', as: 'crear_correo'  
  end
end
