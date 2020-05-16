require 'sinatra/base'
require 'json'
require 'ox'
require_relative 'ledger'

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    get '/expenses/:date' do
      @request_type = request.accept.first.to_s
      date = params[:date]
      results = @ledger.expenses_on(date)
      generate_result(results).tap{|r| p r }
    end

    post '/expenses' do
      @request_type = request.media_type
      expense = parse_body(request)
      result = @ledger.record(expense)

      if result.success?
        generate_result('expense_id' => result.expense_id)
      else
        status 422
        generate_result('error' => result.error_message)
      end
    end

    private

    def parse_body(request)
      body = request.body.read

      if @request_type == 'application/json'
        JSON.parse(body)
      elsif @request_type == 'text/xml'
        Ox.parse_obj(body)
      else
        # OR raise error
        JSON.parse(body)
      end
    end

    def generate_result(data)
      if @request_type == 'application/json'
        JSON.generate(data)
      elsif @request_type == 'text/xml'
        Ox.dump(data)
      else
        # OR raise error
        JSON.generate(data)
      end
    end
  end
end