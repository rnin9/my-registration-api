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
  
end