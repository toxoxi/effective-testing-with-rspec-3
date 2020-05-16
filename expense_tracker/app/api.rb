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
      date = params[:date]
      results = @ledger.expenses_on(date)
      JSON.generate(results)
    end

    post '/expenses' do
      expense = parse_body(request)
      result = @ledger.record(expense)

      if result.success?
        JSON.generate('expense_id' => result.expense_id)
      else
        status 422
        JSON.generate('error' => result.error_message)
      end
    end

    private

    def parse_body(request)
      body = request.body.read

      if request.media_type == 'application/json'
        JSON.parse(body)
      elsif request.media_type == 'text/xml'
        Ox.parse_obj(body)
      else
        # OR raise error
        JSON.parse(body)
      end
    end
  end
end