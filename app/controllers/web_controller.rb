get '/' do
  protect!
  redirect '/projects'
end
