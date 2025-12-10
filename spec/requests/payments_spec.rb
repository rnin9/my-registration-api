require 'swagger_helper'

RSpec.describe 'Payments API' do
  path '/payments' do
    get 'List payments' do
      tags 'Payments'
      security [ Bearer: [] ]
      parameter name: :status, in: :query, type: :string, required: false,
                description: 'Filter by status (PENDING, COMPLETED, CANCELLED, FAILED, REFUNDED)'
      parameter name: :from, in: :query, type: :string, format: :date, required: false,
                description: 'Filter from date (YYYY-MM-DD)'
      parameter name: :to, in: :query, type: :string, format: :date, required: false,
                description: 'Filter to date (YYYY-MM-DD)'
      parameter name: :skip, in: :query, type: :integer, required: false, description: 'Offset for pagination'
      parameter name: :limit, in: :query, type: :integer, required: false, description: 'Limit for pagination'

      response '200', 'success' do
        run_test!
      end
    end

    post 'Create payment' do
      tags 'Payments'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          payment: {
            type: :object,
            properties: {
              actant_id: { type: :string, format: :uuid },
              amount: { type: :integer },
              method: {
                type: :string,
                enum: [ 'card', 'bank_transfer', 'virtual_account', 'mobile', 'kakaopay', 'naverpay' ],
                nullable: true
              },
              status: {
                type: :string,
                enum: [ 'pending', 'completed', 'cancelled', 'failed', 'refunded' ]
              },
              target_type: {
                type: :string,
                enum: [ 'test', 'course' ]
              },
              target_id: { type: :string },
              title: { type: :string },
              paid_at: { type: :string, format: 'date-time', nullable: true },
              valid_from: { type: :string, format: :date },
              valid_to: { type: :string, format: :date }
            },
            required: [ 'actant_id', 'amount', 'status', 'target_type', 'target_id', 'title', 'valid_from', 'valid_to' ]
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

  path '/payments/my' do
    get 'Get my payments' do
      tags 'Payments'
      security [ Bearer: [] ]
      parameter name: :status, in: :query, type: :string, required: false
      parameter name: :from, in: :query, type: :string, format: :date, required: false
      parameter name: :to, in: :query, type: :string, format: :date, required: false
      parameter name: :skip, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response '200', 'success' do
        run_test!
      end
    end
  end

  path '/payments/{id}' do
    parameter name: :id, in: :path, type: :string, format: :uuid

    get 'Get payment' do
      tags 'Payments'
      security [ Bearer: [] ]

      response '200', 'success' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end

    patch 'Update payment' do
      tags 'Payments'
      security [ Bearer: [] ]
      consumes 'application/json'
      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          payment: {
            type: :object,
            properties: {
              amount: { type: :integer },
              method: {
                type: :string,
                enum: [ 'card', 'bank_transfer', 'virtual_account', 'mobile', 'kakaopay', 'naverpay' ],
                nullable: true
              },
              status: {
                type: :string,
                enum: [ 'pending', 'completed', 'cancelled', 'failed', 'refunded' ]
              },
              target_type: {
                type: :string,
                enum: [ 'test', 'course' ]
              },
              target_id: { type: :string },
              title: { type: :string },
              paid_at: { type: :string, format: 'date-time', nullable: true },
              cancelled_at: { type: :string, format: 'date-time', nullable: true },
              valid_from: { type: :string, format: :date },
              valid_to: { type: :string, format: :date },
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

    delete 'Delete payment' do
      tags 'Payments'
      security [ Bearer: [] ]

      response '204', 'deleted' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end
    end
  end

  path '/payments/{id}/restore' do
    parameter name: :id, in: :path, type: :string, format: :uuid

    post 'Restore payment' do
      tags 'Payments'
      security [ Bearer: [] ]

      response '200', 'restored' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/payments/{id}/cancel' do
    parameter name: :id, in: :path, type: :string, format: :uuid

    post 'Cancel payment' do
      tags 'Payments'
      security [ Bearer: [] ]
      description 'Cancel a payment and set cancelled_at timestamp'

      response '200', 'cancelled' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end
  end

  path '/payments/{id}/complete' do
    parameter name: :id, in: :path, type: :string, format: :uuid

    post 'Complete payment' do
      tags 'Payments'
      security [ Bearer: [] ]
      description 'Mark payment as completed and set paid_at timestamp'

      response '200', 'completed' do
        run_test!
      end

      response '403', 'forbidden' do
        run_test!
      end

      response '404', 'not found' do
        run_test!
      end
    end
  end

end