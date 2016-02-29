post '/state/:token' do
  server = Server.find_by(token: params[:token])
  State.create(
    server: server,
    cpu_load: params[:cpu],
    ram_usage: params[:ram],
    uptime: params[:uptime],
    swap_usage: params[:swap],
    disks: JSON.parse(params[:disks])
  )
end
