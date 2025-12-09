require 'swagger_helper'

RSpec.describe 'Auth API' do
  path '/auth/sign-in' do
    post 'Sign in' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :auth, in: :body, schema: {
        type: :object,
        properties: {
          auth: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            }
          }
        }
      }

      response '200', 'success' do
        run_test!
      end
    end
  end

  path '/auth/me' do
    get 'Get current user' do
      tags 'Auth'
      security [ Bearer: [] ]

      response '200', 'success' do
        run_test!
      end
    end
  end

  path '/auth/sign-out' do
    delete 'Sign out' do
      tags 'Auth'
      security [ Bearer: [] ]

      response '204', 'signed out' do
        run_test!
      end
    end
  end
end