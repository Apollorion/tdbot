from td import td
import helpers
import random

weights_dict = {
    "joey": {
        "XLK": 30,
        "SPHD": 30,
        "AMD": 30,
        "VTI": 20,
        "NVDA": 20,
        "AAL": 10,
        "AAPL": 10,
        "O": 10
    },
    "kids": {
        "VTI": 50,
        "XLK": 20,
        "SPHD": 20,
        "AAPL": 10
    }
}

# if weight bias is more than the lowest weight, that stock will never be purchased
weight_bias = 10

# td client
c = td()


def main():
    # shuffle keys so lower weighted things can be purchased
    shuffled_joey = list(weights_dict["joey"].keys())
    random.shuffle(shuffled_joey)
    shuffled_kids = list(weights_dict["kids"].keys())
    random.shuffle(shuffled_kids)

    c.get_accounts()

    order = {
        "joey": process("joey", shuffled_joey),
        "kids": process("emery", shuffled_kids)
    }

    print()

    # purchase symbols
    for account, account_value in c.accounts.items():
        orders = order["kids"]
        if account == "joey":
            orders = order["joey"]

        for symbol, value in orders.items():
            if value["purchase"] > 0:
                c.place_order(symbol, value["purchase"], value["price"], account_value["accountId"])


def process(account, symbol_keys):
    weights = weights_dict["joey"].copy()
    if account != "joey":
        weights = weights_dict["kids"].copy()

    cash = c.get_available_cash(account)
    print(f"{account} has ${cash}")
    cash = cash - 20

    for symbol in symbol_keys:
        price = c.get_symbol_price(symbol)
        weights[symbol] = {"weight": weights[symbol], "price": price}

    weights_saved = weights.copy()

    order = {}

    while True:
        lowest_price = 99999999

        symbol_to_buy = ""
        weight_to_win = 0
        found_winner = False
        for symbol in symbol_keys:
            value = weights[symbol]

            if value["price"] < lowest_price:
                lowest_price = value["price"]

            # this if statement looks dumb just because I want to clearly see the logic
            # check the weight is not less than zero
            if value["weight"] > 0:
                # check the weight is more than the weight to win
                if value["weight"] > weight_to_win:
                    # Check the bias wont go less than 0
                    if (value["weight"] - weight_bias) >= 0:
                        # check that we have enough money to buy it
                        if (cash - value["price"]) >= 0:
                            symbol_to_buy = symbol
                            weight_to_win = value["weight"]
                            found_winner = True

        if not found_winner:
            # if we still have funds to purchase the lowest priced item
            # reset the weights and try again
            if cash > lowest_price:
                weights = weights_saved.copy()
                continue
            else:
                break

        cash = helpers.round_decimals_down(cash - weights[symbol_to_buy]["price"])

        weights[symbol_to_buy] = {
            "weight": weights[symbol_to_buy]["weight"] - weight_bias,
            "price": weights[symbol_to_buy]["price"],
        }

        order[symbol_to_buy] = {"price": weights[symbol_to_buy]["price"], "purchase": 1 if symbol_to_buy not in order else order[symbol_to_buy]["purchase"] + 1}

    print(account, f"will have ${cash + 20} after purchase")
    return order


if __name__ == "__main__":
    main()
