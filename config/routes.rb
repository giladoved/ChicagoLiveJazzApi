Rails.application.routes.draw do
  scope '/api' do
    scope '/greenmill' do
      get '/' => 'green_mill#index'
    end
    scope '/jazzshowcase' do
      get '/' => 'jazz_showcase#index'
    end
  end
end
