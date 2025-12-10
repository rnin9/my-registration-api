require 'swagger_helper'

RSpec.describe 'Tests API' do
  path '/tests' do
    get 'List tests' do
      tags 'Tests'
      parameter name: :status, in: :query, type: :string, description: 'Filter by status (AVAILABLE, IN_PROGRESS, COMPLETED, CANCELLED)'
      parameter name: :sort, in: :query, type: :string, description: 'Sort by (created, popular)'
      parameter name: :skip, in: :query, type: :integer, description: 'Offset for pagination'
      parameter name: :limit, in: :query, type: :integer, description: 'Limit for pagination'

      response '200', 'success' do
        run_test!
      end
    end

    post 'Create test' do
      tags 'Tests'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :test, in: :body, schema: {
        type: :object,
        properties: {
          test: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              start_at: { type: :string, format: 'date-time' },
              end_at: { type: :string, format: 'date-time' },
              status: { type: :string, enum: [ 'available', 'in_progress', 'completed', 'cancelled' ] }
            },
            required: [ 'title', 'description', 'start_at', 'end_at', 'status' ]
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

  path '/tests/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Get test' do
      tags 'Tests'
      response '200', 'success' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end

    patch 'Update test' do
      tags 'Tests'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :test, in: :body, schema: {
        type: :object,
        properties: {
          test: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              examinee_count: { type: :integer },
              start_at: { type: :string, format: 'date-time' },
              end_at: { type: :string, format: 'date-time' },
              status: { type: :string },
              is_destroyed: { type: :boolean }
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

      response '404', 'not found' do
        run_test!
      end
    end

    delete 'Delete test' do
      tags 'Tests'
      security [ Bearer: [] ]

      response '204', 'deleted' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end

  path '/tests/{id}/restore' do
    parameter name: :id, in: :path, type: :integer

    post 'Restore test' do
      tags 'Tests'
      security [ Bearer: [] ]

      response '200', 'restored' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/tests/{id}/apply' do
    parameter name: :id, in: :path, type: :integer

    post 'Apply for test (create payment)' do
      tags 'Tests'
      security [ Bearer: [] ]
      consumes 'application/json'
      description 'Create a payment for a test'
      parameter name: :apply_params, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :integer },
          method: {
            type: :string,
            enum: [ 'card', 'bank_transfer', 'virtual_account', 'mobile', 'kakaopay', 'naverpay' ]
          }
        },
        required: [ 'amount', 'method' ]
      }

      response '201', 'payment created' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 user_id: { type: :string, format: :uuid },
                 amount: { type: :integer },
                 method: { type: :string },
                 status: { type: :string },
                 target_type: { type: :string },
                 target_id: { type: :string },
                 title: { type: :string },
                 valid_from: { type: :string, format: :date },
                 valid_to: { type: :string, format: :date },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               }

        run_test!
      end

      response '404', 'test not found' do
        run_test!
      end

      response '422', 'invalid' do
        run_test!
      end
    end
  end

end