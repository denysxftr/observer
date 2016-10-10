get '/' do
  protect!
  binding.pry
  @servers_with_problem = Server.where(is_ok: false)
  @checks_with_problem = Check.where(is_ok: false)
  erb :'web/index'
end
