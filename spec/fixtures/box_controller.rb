class BoxController < ActionController::Base
  http_basic_authenticate_with name: 'dhh', password: 'secret',
                               except: :index

  def create; end

  def edit; end

  def update; end

  def destroy; end
end
