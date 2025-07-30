require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' # Accede desde http://localhost:3000/sidekiq

  scope '/api' do
    # Ciudades
    get 'ciudades/:id', to: 'ciudades#show', as: 'recupera_ciudad'
    get 'ciudades', to: 'ciudades#index', as: 'recupera_todas_ciudades'
    get 'ciudades/:id/zonas', to: 'ciudades#zonas_por_ciudad', as: 'zonas_por_ciudad'

    # Comercios
    get 'comercios/search', to: 'comercios#search', as: 'busca_comercios'
    get 'comercios/lista', to: 'comercios#lista', as: 'lista_comercios'
    get 'comercios/por_email', to: 'comercios#por_email'
    post 'comercios/no_seprec', to: 'comercios#crear_no_seprec'
    patch 'comercios/:id', to: 'comercios#update', as: 'actualizar_comercio'

    # Zonas
    get 'zonas/active', to: 'zonas#active', as: 'zonas_activas'

    # Correos
    post 'correos', to: 'correos#create', as: 'crear_correo'

    # Solicitudes
    post 'solicitudes', to: 'solicitudes#create', as: 'crear_solicitud'
    get 'solicitudes/buscar_por_token', to: 'solicitudes#buscar_por_token', as: 'buscar_solicitud_por_token'
    patch 'solicitudes/:id', to: 'solicitudes#update', as: 'actualizar_solicitud'
    post 'solicitudes/preparar_escenario', to: 'solicitudes#preparar_escenario'

    # Documentos
    post 'documentos/nit',         to: 'documentos#validar_nit'
    post 'documentos/ci',          to: 'documentos#validar_ci'
    post 'documentos/comprobante', to: 'documentos#validar_comprobante'

    # Inicio
    get 'inicio/objetos', to: 'inicio#objetos'

    # Bloqueo de Correos
    resources :emails_bloqueados, only: [:create]
    delete 'emails_bloqueados/:email', to: 'emails_bloqueados#destroy', constraints: { email: /[^\/]+/ }
    post '/app/cancelar-suscripcion', to: 'unsubs#confirm'

    # Correos Usuarios
    resources :correos_usuarios, only: [:create]

    # Webhook para WhatsApp
    get  'webhooks/whatsapp', to: 'webhooks/whatsapp#verify'
    post 'webhooks/whatsapp', to: 'webhooks/whatsapp#receive'
    namespace :whatsapp do
      resources :mensajes, only: [:create]
    end
    
    # Log CLicks
    resources :log_clics, only: [:create]
  end
end
