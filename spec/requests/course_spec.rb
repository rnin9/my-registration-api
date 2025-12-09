require 'swagger_helper'

RSpec.describe 'Courses API' do
  path '/courses' do
    get 'List courses' do
      tags 'Courses'
      parameter name: :status, in: :query, type: :string, description: 'Filter by status (AVAILABLE, IN_PROGRESS, COMPLETED, CANCELLED)'
      parameter name: :sort, in: :query, type: :string, description: 'Sort by (created, popular)'
      parameter name: :skip, in: :query, type: :integer, description: 'Offset for pagination'
      parameter name: :limit, in: :query, type: :integer, description: 'Limit for pagination'

      response '200', 'success' do
        run_test!
      end
    end

    post 'Create course' do
      tags 'Courses'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          course: {
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

  path '/courses/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Get course' do
      tags 'Courses'
      response '200', 'success' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end

    patch 'Update course' do
      tags 'Courses'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          course: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              student_count: { type: :integer },
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

    delete 'Delete course' do
      tags 'Courses'
      security [ Bearer: [] ]

      response '204', 'deleted' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end

  path '/courses/{id}/restore' do
    parameter name: :id, in: :path, type: :integer

    post 'Restore course' do
      tags 'Courses'
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