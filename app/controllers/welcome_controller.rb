class WelcomeController < ApplicationController
  def index
    @data = Stream.first.datapoints.map do |datapoint|
      [datapoint.created_at.to_i, datapoint.value.to_f]
    end
  end
end
