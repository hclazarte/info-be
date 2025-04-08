class AddComprobanteImagenToSolicitudes < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitudes, :comprobante_imagen, :binary
  end
end
