module ApplicationHelper
  def make_response(instance)
    name_of_class = instance.class.name.downcase
    if instance.valid?
      redirect "/#{name_of_class}/#{instance.id}"
    else
      session[:alert] = instance.errors.full_messages.join(' ')
      erb :"#{name_of_class}s/new"
    end
  end

  def make_update_response(instance)
    if instance.valid?
      redirect "/#{instance.class.name.downcase}/#{instance.id}"
    else
      erb :"#{instance.class.name.downcase}s/edit"
    end
  end

  def server_params(params)
    {
      name: params[:name],
      project: !params[:project_id].empty? && Project.find(params[:project_id]),
      emails: params[:emails] || []
    }
  end

  def project_params(params)
    {
      name: params[:name]
    }
  end

  def check_params(params)
    {
      url: params[:url],
      name: params[:name],
      project: !params[:project_id].empty? && Project.find(params[:project_id]),
      emails: params[:emails] || [],
      expected_ip: params[:expected_ip],
      expected_status: params[:expected_status],
      retries: params[:retries]
    }
  end

  def user_params(params)
    accepted_params = %w[email name].tap do |attrs|
      attrs << 'password' if @user&.new_record? || params[:password] && !params[:password].empty?
      attrs << 'role' if current_user.admin?
    end

    params.select { |k, _| accepted_params.include?(k) }
  end

  def alert
    session.delete(:alert)
  end

  def notice
    session.delete(:notice)
  end

  def assets_tags
    assets = nil
    tries = 5
    loop do
      assets = read_manifest rescue nil

      if assets
        break
      else
        puts 'Assets not ready'
        sleep(1)
      end

      if tries == 0
        puts('Assets not found!')
        return
      end
      tries -= 1
    end

    js_tag = "<script src='/assets/#{assets[:js]}' type='text/javascript'></script>"
    css_tag = "<link rel='stylesheet' type='text/css' href='/assets/#{assets[:css]}'>"

    js_tag + css_tag
  end

private

  def read_manifest
    result = {}
    manifest = JSON.parse(File.read(File.join(settings.public_folder, 'assets/manifest.json')))
    result[:js] = manifest['application.js']
    result[:css] = manifest['application.css']

    result
  end
end
