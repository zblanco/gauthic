defmodule GauthicTest do
  use ExUnit.Case
  doctest Gauthic

  alias Gauthic.{Credentials, Token}

  describe "jwt building" do

    test "a valid jwt can be fetched from Google's Auth Service" do
      assert false
    end

    test "we can build a jwt" do
      assert false
    end

    test "we can build a jwt with an impersonated user" do
      assert false
    end

  end

  describe "token caching" do

    test "we can cache fetched tokens" do
      assert false
    end

    test "expired tokens are removed from the cache" do
      assert false
    end

  end

  test "google service account json can be converted to a Credentials struct" do
    decoded_creds = %{
      "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
      "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
      "client_email" => "test@test.com",
      "client_id" => "some_sequence_of_integers",
      "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/test-test%40test-auth.iam.gserviceaccount.com",
      "private_key" => "definitely_not_a_real_private_key",
      "private_key_id" => "private_key_id",
      "project_id" => "test-test",
      "token_uri" => "https://oauth2.googleapis.com/token",
      "type" => "service_account"
    }
    {:ok, creds} = Credentials.new(decoded_creds)

    assert %Credentials{} = creds
  end

  describe "token fetching" do
    test "we can get OAuth tokens for service accounts" do
      assert false
    end

    test "we can get google compute tokens" do
      assert false
    end

    test "we can get refresh tokens" do
      assert false
    end
  end



end
