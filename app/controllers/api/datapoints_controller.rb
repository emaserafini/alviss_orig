module API
  class DatapointsController < ActionController::Base
    before_action :get_stream
    append_before_action :authenticate, only: :create

    def index
      render json: stream.datapoints
    end

    def create
      datapoint = stream.datapoint_class.new(datapoint_params.merge(stream: stream))
      if datapoint.save
        render json: datapoint, status: :created
      else
        render json: { errors: datapoint.errors }, status: :unprocessable_entity
      end
    end


    private

    def stream
      @stream ||= Stream.find_by identity_token: params[:stream_identity_token]
    end

    def render_no_record_found
      render json: 'no record is found', status: 404
    end

    def get_stream
      stream || render_no_record_found
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        stream.access_token == token
      end
    end

    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: 'invalid token', status: 401
    end

    def authenticate
      authenticate_token || render_unauthorized
    end

    def datapoint_params
      params.require(stream.kind).permit(:value)
    end
  end
end
