require './app/controllers/app.rb'

use Rack::MethodOverride

run App
