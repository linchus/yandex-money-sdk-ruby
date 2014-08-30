# YandexMoney Api

Simple gem for Yandex Money usage.

## Installation

Add this line to your application's Gemfile:

    gem 'yandex-money-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex-money-ruby

## Usage

### 1. Initialize API

```ruby
# If TOKEN was obtained previosly
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
```

```ruby
# If TOKEN need to be obtained
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
```

### 2. User browser OS to send auth request to Yandex.Money server

After visiting `api.client_url` client will be redirected to `REDIRECT_URL` with `code` parameter. It is authorization code, needed for token obtaining.

To get token use `YandexMoney::Api#obtain_token`:

```ruby
  api.code = "ACEB6F56EC46B66F280AFB9C805C61A66A8B5" # obtained code
  token = api.obtain_token # token contains valid client token
```

## Methods

### Information about a user's account

#### account-info method

Getting information about the status of the user account. Required permissions: `account-info`.

```ruby
  api.account_info
  #<OpenStruct account="41001565326286", balance=48.98, currency="643", avatar={"ts"=>"2012-05-02T17:22:59.000+04:00", "url"=>"https://avatars.yandex.net/get-yamoney-profile/yamoney-profile-56809635-2/normal?1335964979000"}, account_type="personal", identified=false, account_status="named">
```

#### operation-history method

This method allows viewing the full or partial history of operations in page mode. History records are displayed in reverse chronological order (from most recent to oldest).

Required permissions: `operation-history`.

```ruby
  api.operation_history
  #<OpenStruct next_record="30", operations=[{"operation_id"=>"462449992116028008", "title"=>"Возврат средств от:", "amount"=>1.0, "direction"=>"in", "datetime"=>"2014-08-27T10:19:52Z", "status"=>"success", "type"=>"deposition"}, ..., {"pattern_id"=>"p2p", "operation_id"=>"460970888534110007", "title"=>"Перевод на счет 410011700000000", "amount"=>3.02, "direction"=>"out", "datetime"=>"2014-08-10T07:28:15Z", "status"=>"success", "type"=>"outgoing-transfer"}]>
```

#### operation-details method

Provides detailed information about a particular operation from the history.

Required permissions: `operation-details`.

```ruby
  api.operation_details(OPERATION_ID)
  #<OpenStruct operation_id="462449992116028008", title="Возврат средств от:", amount=1.0, direction="in", datetime="2014-08-27T10:19:52Z", status="success", type="deposition", details="Отмена оплаты по банковской карте Яндекс.Денег\n , 5411, , \nНомер транзакции: 423910208430140827101810\nСумма в валюте платежа: 1.00 RUB">
```

If operation not exists, exception will be raised:

```ruby
  api.operation_details "unknown"
  #   RuntimeError:
  #     Illegal param operation id
```

If scope insufficient, expcetion will be raised:

```ruby
  api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history", TOKEN)
  api.operation_details(OPERATION_ID)
  #  RuntimeError:
  #     Insufficient Scope
```

## Caveats

This library very unstable. Pull requests welcome!

## Contributing

1. Fork it ( https://github.com/drakmail/yandex-money-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write tests with rspec + VCR
4. Write code
5. Test code
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a new Pull Request
