require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RECORD_KEYS = ['payee', 'amount', 'date']

  class Ledger
    def record(expense)
      RECORD_KEYS.each do |key|
        unless expense.key?(key)
          message = "Invalid expense: `#{key}` is required"
          return RecordResult.new(false, nil, message)
        end
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end
  end
end
