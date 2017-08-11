Rails.application.routes.draw do
  scope '/api' do
    scope '/greenmill' do
      get '/' => 'green_mill#index'
    end
  end
end
