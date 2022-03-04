import tda
from tda.orders.equities import equity_buy_limit
import os


class td:

    def __init__(self):
        self.account = {}
        self.symbol_cache = {}

        path = "/token/token.json"
        key = "AWOKTXPCODG4FNASJJRRTEIIVF8XQ0JH"
        try:
            self.c = tda.auth.client_from_token_file(path, key)
        except:
            print("failed to auth")
            self.c = tda.auth.client_from_manual_flow(key, "https://apollorion.com/callback", path)

    def get_account(self, account_id):
        accounts_response = self.c.get_accounts()
        found = False
        if accounts_response.status_code == 200:
            for account in accounts_response.json():
                if account["securitiesAccount"]["accountId"] == str(account_id):
                    found = True
                    self.account = account["securitiesAccount"]

            if not found:
                raise Exception(f"could not find account {account_id}")

        else:
            raise Exception("failed to get accounts")

    def get_symbol_price(self, symbol) -> float:
        if symbol in self.symbol_cache.keys():
            low_price = self.symbol_cache[symbol]["lowPrice"]
            ask_price = self.symbol_cache[symbol]["askPrice"]
            test = [low_price, ask_price]
            return min(test)

        quote = self.c.get_quote(symbol)
        if quote.status_code == 200:
            r = quote.json()
            self.symbol_cache[symbol] = r[symbol]

            low_price = r[symbol]["lowPrice"]
            ask_price = r[symbol]["askPrice"]
            test = [low_price, ask_price]
            return min(test)
        else:
            raise Exception("failed to get quote")

    def get_available_cash(self) -> float:
        current = self.account["currentBalances"]["cashAvailableForTrading"]
        projected = self.account["projectedBalances"]["cashAvailableForTrading"]
        return min([current, projected])

    def place_order(self, symbol, amount_to_order, limit_price):
        account_id = self.account["accountId"]
        print(f"ordering {amount_to_order} of {symbol} for {account_id} at ${limit_price} each")
        if "WEIGHTS" in os.environ:
            order = equity_buy_limit(symbol, amount_to_order, limit_price).build()
            self.c.place_order(account_id, order)
        else:
            print("SIMULATING ORDER")
