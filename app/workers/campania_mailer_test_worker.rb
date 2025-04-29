class CampaniaMailerTestWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 0

  def perform
    comercio = OpenStruct.new(
      id: 999999,
      email: "hclazarte@gmail.com",
      empresa: "GEOSOFT INTERNACIONAL SRL",
      ciudad: OpenStruct.new(nombre: "La Paz")
    )

    CampaniaMailer.promocion_comercio(comercio).deliver_now
  end
end
