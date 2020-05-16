require_relative '../../../app/api'
require 'rack/test'
require 'ox'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do

      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        context 'JSON format' do
          it 'returns the expense id' do
            post '/expenses', JSON.generate(expense)

            response_body = JSON.parse(last_response.body)
            expect(response_body).to include('expense_id' => 417)
          end
          
          it 'responds with a 200 (OK)' do
            post '/expenses', JSON.generate(expense)

            expect(last_response.status).to eq(200)
          end
        end

        context 'XML format' do
          before do
            header 'Content-Type', 'text/xml'
          end

          it 'returns the expense id' do
            post '/expenses', Ox.dump(expense)

            response_body = Ox.parse_obj(last_response.body)
            expect(response_body).to include('expense_id' => 417)
          end
          
          it 'responds with a 200 (OK)' do
            post '/expenses', Ox.dump(expense)

            expect(last_response.status).to eq(200)
          end
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        context 'JSON format' do
          it 'returns an error message' do
            post '/expenses', JSON.generate(expense)

            response_body = JSON.parse(last_response.body)
            expect(response_body).to include('error' => 'Expense incomplete')
          end
          
          it 'responds with a 422 (Unprocessable entity)' do
            post '/expenses', JSON.generate(expense)

            expect(last_response.status).to eq(422)
          end
        end

        context 'XML format' do
          before do
            header 'Content-Type', 'text/xml'
          end

          it 'returns an error message' do
            post '/expenses', Ox.dump(expense)

            response_body = Ox.parse_obj(last_response.body)
            expect(response_body).to include('error' => 'Expense incomplete')
          end
          
          it 'responds with a 422 (Unprocessable entity)' do
            post '/expenses', Ox.dump(expense)

            expect(last_response.status).to eq(422)
          end
        end
      end
    end

    describe 'GET /expenses/:date' do
      let(:date) { '2017-06-12' }

      context 'when expenses exist on the given date' do
        let(:records) { [
          RecordResult.new(true, 417, nil),
          RecordResult.new(true, 418, nil),
          RecordResult.new(true, 419, nil),
        ] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(records)
        end

        shared_examples 'return records' do
          it 'returns the expense records' do
            get '/expenses/2017-06-12'
            expect(last_response.body).to eq(expected_records)
          end
          
          it 'responds with a 200 (OK)' do
            get '/expenses/2017-06-12'
            expect(last_response.status).to eq(200)
          end
        end
        
        context 'JSON format' do
          let(:expected_records) { JSON.generate(records) }
          it_behaves_like 'return records'
        end

        context 'XML format' do
          before do
            header 'Accept', 'text/xml'
          end

          let(:expected_records) { Ox.dump(records) }
          it_behaves_like 'return records'
        end
      end

      context 'when there are no expenses on the given data' do
        let(:records) { [] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(records)
        end

        shared_examples 'return empty array' do          
          it 'returns an empty array' do
            get '/expenses/2017-06-12'
            expect(last_response.body).to eq(expected_records)
          end
          
          it 'responds with a 200 (OK)' do
            get '/expenses/2017-06-12'
            expect(last_response.status).to eq(200)
          end
        end

        context 'JSON format' do
          let(:expected_records) { JSON.generate(records) }
          it_behaves_like 'return empty array'
        end
        
        context 'XML format' do
          before do
            header 'Accept', 'text/xml'
          end

          let(:expected_records) { Ox.dump(records) }
          it_behaves_like 'return empty array'
        end
      end
    end
  end
end
