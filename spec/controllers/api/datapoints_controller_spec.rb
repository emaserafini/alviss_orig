require 'rails_helper'

RSpec.describe API::DatapointsController, type: :controller do
  let!(:stream) { create :stream }

  describe 'GET #index datapoints' do
    context 'when stream is not present' do
      it 'returns 404 status' do
        get :index, { stream_identity_token: 4 }
        expect(response.status).to eq 404
      end

      it 'returns json message error' do
        get :index, { stream_identity_token: 4 }
        expect(response.body).to eq('no record is found')
      end
    end

    context 'when stream is present' do
      it 'retrurn 200 status' do
        get :index, { stream_identity_token: stream.identity_token }
        expect(response.status).to eq 200
      end

      context 'with no datapoints' do
        it 'retrurns an empty json array' do
          get :index, { stream_identity_token: stream.identity_token }
          body = JSON.parse response.body
          expect(body).to be_empty
        end
      end

      context 'with datapoints' do
        let(:body) { JSON.parse response.body, symbolize_names: true }

        before do
          create_list :temperature, 3, stream: stream
          get :index, { stream_identity_token: stream.identity_token }
        end

        it 'returns an array of json' do
          expect(body).to be_kind_of Array
        end

        it 'returns correct data' do
          result_values = body.map{ |point| point[:value] }
          stream_values = Datapoint::Temperature.of_stream(stream.id).pluck(:value).map(&:to_s)
          expect(result_values).to eq stream_values
        end
      end
    end
  end

  describe 'POST #create datapoint' do
    context 'for non existing stream' do
      it 'returns 404 status' do
        post :create, { stream_identity_token: 4, 'temperature': { 'value': 20 } }
        expect(response.status).to eq 404
      end

      it 'returns json message error' do
        post :create, { stream_identity_token: 4, 'temperature': { 'value': 20 } }
        expect(response.body).to eq('no record is found')
      end
    end

    context 'for existing stream' do
      let(:valid_token) { ActionController::HttpAuthentication::Token.encode_credentials(stream.access_token) }
      let(:invalid_token) { ActionController::HttpAuthentication::Token.encode_credentials('invalid_token') }

      context 'when is passed a valid access_token' do
        context 'when datapoint can be saved' do
          it 'returns 201 status' do
            request.env['HTTP_AUTHORIZATION'] = valid_token
            post :create, { stream_identity_token: stream.identity_token, 'temperature': { 'value': 20 } }
            expect(response.status).to eq 201
          end

          it 'retruns creted datapoints in json' do
            request.env['HTTP_AUTHORIZATION'] = valid_token
            post :create, { stream_identity_token: stream.identity_token, 'temperature': { 'value': 20 } }
            body = JSON.parse(response.body, symbolize_names: true)
            expect(body[:value]).to eq '20.0'
          end
        end

        context 'when datapoint cannot be saved' do
          it 'returns 422 status' do
            request.env['HTTP_AUTHORIZATION'] = valid_token
            post :create, { stream_identity_token: stream.identity_token, 'temperature': { 'value': nil } }
            expect(response.status).to eq 422
          end

          it 'returns erorrs' do
            request.env['HTTP_AUTHORIZATION'] = valid_token
            post :create, { stream_identity_token: stream.identity_token, 'temperature': { 'value': nil } }
            expect(response.body).to include 'is not a number'
          end
        end
      end

      context 'when is passed an invalid access_token' do
        it 'returns 401 status' do
          request.env['HTTP_AUTHORIZATION'] = invalid_token
          post :create, { stream_identity_token: stream.identity_token, 'temperature': { 'value': 20 } }
          expect(response.status).to eq 401
        end
      end
    end
  end
end
