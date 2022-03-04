from td import td
import helpers
import random
import os
import json
import aws

weights_dict = json.loads(os.environ["WEIGHTS"]) if "WEIGHTS" in os.environ else {
    "account": int(os.environ["ACCOUNT_ID"]),
    "weights": {
        "XLK": 30,
        "SPHD": 30,
        "AMD": 30,
        "VTI": 20,
        "NVDA": 20,
        "AAL": 10,
        "AAPL": 10,
        "O": 10
    }
}

# if weight bias is more than the lowest weight, that stock will never be purchased
weight_bias = 10

# td client
aws.get_token()
c = td()
aws.set_token()


def main():
    # shuffle keys so lower weighted things can be purchased
    shuffled_keys = list(weights_dict["weights"].keys())
    random.shuffle(shuffled_keys)

    c.get_account(weights_dict["account"])
    order = process(shuffled_keys)
    # purchase symbols
    for symbol, value in order.items():
        if value["purchase"] > 0:
            c.place_order(symbol, value["purchase"], value["price"])


def process(symbol_keys):
    weights = weights_dict["weights"].copy()

    cash = c.get_available_cash()
    print(f"account has ${cash}")

    compare = {}
    for symbol in symbol_keys:
        price = c.get_symbol_price(symbol)
        compare[symbol] = {"weight": weights[symbol], "price": price}

    compare_saved = compare.copy()
    order = {}

    previous_winner_failed = False
    while True:
        lowest_price = 99999999999

        symbol_to_buy = ""
        weight_to_win = 0
        found_winner = False
        for symbol in symbol_keys:
            value = compare[symbol]

            if value["price"] < lowest_price:
                lowest_price = value["price"]

            # this if statement looks dumb just because I want to clearly see the logic
            # check the weight is not less than zero
            if value["weight"] >= 0:
                # check the weight is more than the weight to win
                if value["weight"] > weight_to_win or previous_winner_failed:
                    # Check the bias wont go less than 0
                    if (value["weight"] - weight_bias) >= 0 or previous_winner_failed:
                        # check that we have enough money to buy it
                        if (cash - value["price"]) >= 0:
                            previous_winner_failed = False
                            symbol_to_buy = symbol
                            weight_to_win = value["weight"]
                            found_winner = True

        if not found_winner:
            # if we still have funds to purchase the lowest priced item
            # reset the weights and try again
            if cash > lowest_price:
                previous_winner_failed = True
                compare = compare_saved.copy()
                continue
            else:
                break
        else:
            cash = helpers.round_decimals_down(cash - compare[symbol_to_buy]["price"])
            compare[symbol_to_buy]["weight"] = compare[symbol_to_buy]["weight"] - weight_bias

            if symbol_to_buy in order:
                order[symbol_to_buy]["purchase"] += 1
            else:
                order[symbol_to_buy] = {"purchase": 1, "price": compare[symbol_to_buy]["price"]}

    print(f"will have ${cash} after purchase")
    return order


if __name__ == "__main__":
    main()
