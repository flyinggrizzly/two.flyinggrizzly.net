# FBAR Prep

[fbar-prep](https://github.com/flyinggrizzly/fbar-prep) is a tool to make preparing for FBAR reports easier.

It takes a pile of CSV data from bank accounts, some YAML mappings to tell it where different kinds of data can be found
in those CSVs, and spits out a new CSV report that tells you:

- which date had the highest combined total across the accounts
- what the total was on each account on that date
- what the USD value was for each account on that date, based on the IRS' published average exchange rate per-currency
  for the year
- what the end of year total was in each account

It's really the first two questions that are a pain in the ass to figure out. Thank you IRS, you all suck and make our
lives as expats a real slog once a year.

## The fun code part

The interesting part of this tool for me was not the work to find the date with the highest total (though there could be
better ways than what I've done, which is just iterate across all dates in the year), but the mapping code I wrote to
handle YAML declarations of some basic computations.

Not all bank export CSVs look the same, but to calculate FBAR reports we need the same basic information:

- date
- balance on the date

Some accounts give you a date, and a delta amount per-transaction, some include the resulting balance.

In order to support this, and to have some fun and challenge myself with a weekend project, I set it up so that with a
YAML like this:

```yaml
mappings:
  date: Date
  detail: Transaction Information
  balance:
    compute:
      add:
        - $TRANSACTIONS.PREVIOUS_BALANCE
        - Amount
```

the tool will understand that to get the required information for the row transaction, it needs to:

- get the `date` from the "Date" column, and transaction `detail` from the "Transaction Information" column
- get the previous balance as resolved over the previous row(s) (also computed in this same way, with an assumed
  starting value of 0 unless there's a beginning value inferred from a previous year or explicitly provided)
- compute the `balance` value, with an Addition operation, on the previous balance and the "Amount" column in the CSV
  export

There are [a few other computations
supported](https://github.com/flyinggrizzly/fbar-prep/blob/main/docs/computations.md), though not many. Turns out the
accounts I have have relatively limited requirements for these.

Each computation is handled by a service object with a name like `Computation::Addition` that accepts a row, and the
current state (providing previous row data and resolved values).

An iterator runs over the rows in the file, with the YAML mapping in memory, and resolves all required and mapped values
for each row.

It's not massively efficient, but then it doesn't need to be. The real slowdown at the moment is that the YAML is
evaluated per-row, which is pretty wasteful.

On the other hand, this tool is already significantly more efficient and less error prone than doing this work by hand.
And it still runs my accounts in a few seconds. "Inefficient" here is both noticeable, and unimportant. (Though I do
have ideas of how I'd improve it if I needed to. But I don't. And that weekend time is better spent elsewhere)
