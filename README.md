# holidays-api

## Development setup (using docker)

1. Create `.env` from related `.example` files and set all needed variables:

        cp .env.example .env

2. Ask team members about `master.key`

3. Install [docker](https://docs.docker.com/engine/installation/) & [docker-compose](https://docs.docker.com/compose/install/) if you haven't got them yet and then run:

        docker-compose build

4. Run the project:

        docker-compose up
        docker-compose up -d # without logs

5. Setup development & test db's:

        docker-compose exec web rake db:setup

## API v.1
### Authentification
  Send POST request to `api/v1/auth` with body `{ email: 'some@email.com', password: 'some_pass' }`
  
  Returns JSON like: `{ "token": "YOUR_TOKEN" }`
  
  Then for each request add header `Authorization: Bearer YOUR_TOKEN`
### Using
#### CRUD:
```ruby
  get 'api/v1/countries'
  post 'api/v1/countries'       # create | params: %i[ja_name en_name country_code]
  patch 'api/v1/countries/:id'  # update | params: %i[ja_name en_name country_code]
  delete 'api/v1/countries/:id' # destroy

  post 'api/v1/holidays'       # create | params: %i[ja_name en_name country_code expression calendar_type holiday_type]
  patch 'api/v1/holidays/:id'  # update | params: %i[ja_name en_name country_code expression calendar_type holiday_type]
  delete 'api/v1/holidays/:id' # destroy
```
#### Deal with holidays:
```ruby
  get 'api/v1/holidays'                     # for all countries in Date.current.all_year
  get 'api/v1/holidays/:country_code'       # for one country in Date.current.all_year
  get 'api/v1/holidays/:country_code/:year' # for one country in :year
  # also you can use 'from' and 'to' params for determite the period and it can be used with :country_code
  # default: from = Date.current.beginning_of_year
  #          to   = Date.current.end_of_year
  get 'api/v1/holidays?from=Y-m-d&to=Y-m-d'
  post 'api/v1/holidays/:id/move?from=Y-m-d&to=Y-m-d' # move one day of holiday to another
```

## HolidayExpr `expression` formats:
  - Simple: `Y?/m/d`:
    ```ruby
      2018/01/01
      01/01
      2018/01/01
      2018.1.1
      1.1
    ```
  - Nth Day: `Y?/N,day_of_week`:
    ```ruby
      10/1,5       # first friday of October
      2018/1,5     # first friday of October 2018
      1.-1,2       # last tuesday of January
      2018.11.-2,7 # penultimate sunday of November 2018
    ```
  - Period: `Y?/m/day_from-day_to`:
    ```ruby
      10/1-15    # from the 1st to the 15th of October
      1.23-25    # from the 23th to the 25th of January
      2018.2.1-3 # from the 1st to the 3rd of February in 2018
    ```
  - Larger period (yes, brackets is required): `Y?/(month_from/day_from)-(month_to/day_to)`
    ```ruby
      (1/15)-(2/5)        # from the 15th of January to the 5th of February
      2018/(05/30)-(06/5) # from the 30th of May to the 5th of June in 2018
      (12/31)-(1/6)       # from the 31th of December to the 6th of January (New Year (^-^))
    ```
  - Full moon: `Y?/m/full.*moon`:
    ```ruby
      2018/01/full_moon # full moon in January 2018
      1.fullmoon        # full moon in January
      05.full_moon      # full moon in May
      1976/9.full-moon  # full moon in September 1976
      1976/9.full-so-full-that-it-took-the-squirrel-away-moon # full moon in September 1976 too
    ```

##### Note: delimiter can be `/` or `.`
##### Note: if `year` is not presented app will generate Holidays from 1970 to 2038
