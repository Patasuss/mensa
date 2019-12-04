# mensa
Usage: `./mensa`
Prints todays mealplan of the Universität Bremen Mensa

# Building
- Clone this repo
- Install nim 
  - I used version `1.0.99` while building, older version might work
- `cd` into the cloned repo
- Compile with `nim -d:ssl mensa.nim`
- If everything compiles correctly, you'll have a `mensa` executable in your folder
- Done

# TODO
- Print prices for employees, too
- Make it possible to show mealplans for other days
- Make it possible to supply own source link via CLI
