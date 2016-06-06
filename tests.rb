require 'pry'
require 'minitest/autorun'
require 'minitest/focus'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

require 'rack/test'

require "./app"

class ColosonTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Coloson
  end

  def setup
    app.reset_database
  end

  def test_it_can_store_numbers
    response = get "/numbers/evens"

    assert_equal 200, response.status
    assert_equal "[]", response.body

    post "/numbers/evens", number: 2
    post "/numbers/evens", number: 14
    post "/numbers/evens", number: 8

    response = get "/numbers/evens"
    assert_equal 200, response.status
    assert_equal [2,14,8], JSON.parse(response.body)
  end

  def test_it_resets_between_tests
    response = get "/numbers/evens"

    assert_equal 200, response.status
    assert_equal "[]", response.body
  end

  def test_it_can_delete_numbers
    skip
    post "/numbers/odds", number: 5
    post "/numbers/odds", number: 13

    response = get "/numbers/odds"
    assert_equal 200, response.status
    assert_equal [5,13], JSON.parse(response.body)

    delete "/numbers/odds", number: 5
    response = get "/numbers/odds"
    assert_equal [13], JSON.parse(response.body)
  end

  def test_it_wont_add_non_numbers
    response = post "/numbers/odds", number: "eleventy"
    assert_equal 422, response.status

    body = JSON.parse response.body
    assert_equal "error", body["status"]
    assert_equal "Invalid number: eleventy", body["error"]
  end

  def test_it_can_sum_numbers
    post "/numbers/primes", number: 7
    post "/numbers/primes", number: 541
    post "/numbers/primes", number: 31

    response = get "/numbers/primes/sum"
    assert_equal 200, response.status

    body = JSON.parse response.body
    assert_equal "ok", body["status"]
    assert_equal 579, body["sum"]
  end

  def test_it_can_multiply_small_numbers
    1.upto(4).each do |i|
      post "/numbers/mine", number: i
    end

    response = get "/numbers/mine/product"
    assert_equal 200, response.status

    body = JSON.parse response.body
    assert_equal "ok", body["status"]
    assert_equal 24, body["product"]
  end

  def test_it_cant_multiply_larger_numbers
    1.upto(10).each do |i|
      post "/numbers/mine", number: i
    end

    response = get "/numbers/mine/product"
    assert_equal 422, response.status

    body = JSON.parse response.body
    assert_equal "error", body["status"]
    assert_equal "Only paid users can multiply numbers that large", body["error"]
  end
end
