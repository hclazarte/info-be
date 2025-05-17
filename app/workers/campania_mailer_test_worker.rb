class CampaniaMailerTestWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 0

  def perform
    campania = OpenStruct.new(
      id: 999999,
      empresa: "GEOSOFT INTERNACIONAL SRL",
      email: "hclazarte@hotmail.com"
      ciudad: OpenStruct.new(nombre: "La Paz"),
      id_comercio: 53257
    )

    CampaniaMailer.promocion_comercio(campania).deliver_now
  end
end
