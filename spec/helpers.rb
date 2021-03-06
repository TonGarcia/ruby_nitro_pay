require 'file_helper'
module Helpers
  def http_success
    200
  end

  def accessible?(url)
    RestClient.proxy = NitroPay.proxy if NitroPay.proxy && NitroPay.proxy.index('your_login').nil?
    resp = RestClient.get url
    RestClient.proxy = nil
    resp.code == 200 ? true : false
  end

  def fake_sold_items
    sold_items = []

    count = 0
    items_amount = 3

    until count == items_amount do
      count = count+1
      rand_count_departments = Random.new.rand(1..10)
      sold_item = {
          remote_id: Faker::Number.number(count),
          name: Faker::Commerce.product_name,
          description: Faker::Commerce.department(rand_count_departments, rand_count_departments==2)
      }

      sold_items << sold_item
    end

    sold_items
  end

  def get_json url
    resp = RestClient.get url
    JSON.parse(resp).it_keys_to_sym
  end

  def page_transaction_mock(card_brand, amount, redir_link)
    page = {}
    page[:transaction] = NitroPay::Transaction.new({
      card:{brand: card_brand},
      clients:{name:Faker::Name.name, email:Faker::Internet.free_email, legal_id:CPF.generate},
      amount: amount, # The last 2 numbers are the cents
      redirect_link: redir_link # (* optional) used only for CieloPage
    })

    # Fake SoldItems added
    page[:transaction].sold_items = fake_sold_items

    # Perform BuyPage
    page[:resp] = page[:transaction].charge_page
    page
  end
end