require "spec_helper"

CLIENT_ID = "84ED7836D6C0273670C2BA5616AFC9B810F56C10E1F272467E0C158B6232E0E8"
REDIRECT_URI = "http://drakmail.github.io/yandex-money-ruby"

describe YandexMoney::Api do
  describe "auth" do
    # http://api.yandex.ru/money/doc/dg/reference/request-access-token.xml
    it "should properly initialize without client_secret" do
      VCR.use_cassette "init without client secret" do
        api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        expect(api.client_url).to start_with("https://money.yandex.ru/select-wallet.xml?requestid=")
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/obtain-access-token.xml
    it "should get token from code" do
      VCR.use_cassette "get token from authorization code" do
        api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history")
        api.code = "736557BEBF03A1867FFF179F8FADF0F33841471B31BD9ECF2AC59480D0F123475E6261300B1FED6CDB7C067EF4C5E9CC860A31839D52FA5950B5CAFD18C29FE0A31D2F53618D000BAA7C733B2A143C148C4631EFDEAB29151A5EA92B6B099AAEE31A82BF9F7C13EC2E8EAFF44F62D1326EDEBDA4668631ACC367967DDA57F875"
        api.obtain_token
        expect(api.token).to start_with("41001565326286.D206A82773387134BB25CF89A85256EA")
      end
    end
  end

  describe "get account info" do
    before :all do
      VCR.use_cassette "obtain token for get account info" do
        @api = YandexMoney::Api.new(CLIENT_ID, REDIRECT_URI, "account-info operation-history operation-details")
        @api.code = "39041180F6631E2B56DD0058F75A34C7504226178A45D624313495ECD417DCC3AA6CBF1B010E65BB09F3F9EB5AE63452129BAE2B732B7457C33BE6B2039B7B60A8058D2A387729A601DC817BBFB27CB0CC2D65E3C70997D981AC0E31F18CF32C0675DFD461E2F5C5639B75AC0E5074CE64FCF4546447BBDC566E3459FB1B3C3B"
        @api.obtain_token
      end
    end

    # http://api.yandex.ru/money/doc/dg/reference/account-info.xml
    it "should return account info" do
      VCR.use_cassette "get account info" do
        info = @api.account_info
        expect(info.account).to eq("41001565326286")
      end
    end

    # http://api.yandex.com/money/doc/dg/reference/operation-history.xml
    it "should return operation history" do
      VCR.use_cassette "get operation history" do
        history = @api.operation_history
        expect(history.operations.count).to eq 30
      end
    end

    # http://api.yandex.com/money/doc/dg/reference/operation-details.xml
    describe "operation details" do
      it "should return valid operation details" do
        VCR.use_cassette "get operation details" do
          details = @api.operation_details "462449992116028008"
          expect(details.status).to eq "success"
        end
      end

      it "should raise exception if operation_id is wrong" do
        VCR.use_cassette "get wrong operation details" do
          expect { @api.operation_details "unknown" }.to raise_error "Illegal param operation id"
        end
      end
    end
  end
end
