require 'swagger_helper'

RSpec.describe 'Users API' do
  path '/users' do
    get 'List users' do
      tags 'Users'
      response '200', 'success' do
        run_test!
      end
    end

    post 'Create user (Sign up)' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              name: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: [ 'email', 'name', 'password', 'password_confirmation' ]
          }
        }
      }

      response '201', 'created' do
        run_test!
      end

      response '422', 'invalid' do
        run_test!
      end
    end
  end

  path '/users/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Get user' do
      tags 'Users'
      response '200', 'success' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end

    patch 'Update user' do
      tags 'Users'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string }
            }
          }
        }
      }

      response '200', 'updated' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end

    delete 'Delete user' do
      tags 'Users'
      security [ Bearer: [] ]

      response '204', 'deleted' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end

  path '/users/{id}/restore' do
    parameter name: :id, in: :path, type: :integer

    post 'Restore user' do
      tags 'Users'
      security [ Bearer: [] ]

      response '200', 'restored' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end
  end
end