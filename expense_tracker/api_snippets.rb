class API < Sinatra::Base
  def initialize
    @ledger = Ledger.new
    super() # rest of initialization from Sinatra
  end
end

app = API.new
