class AddFechaFinServicioToSolicitudes < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitudes, :fecha_fin_servicio, :datetime
  end
end
