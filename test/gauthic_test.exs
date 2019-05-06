defmodule GauthicTest do
  use ExUnit.Case
  doctest Gauthic

  alias Gauthic.{Credentials, Token}
  alias GoogleAuthMock

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

  describe "token_building" do

    test "tokens can be built from HTTPact.Response" do
      response = %HTTPact.Response{
        body: "{\"access_token\":\"some_access_token\",\"expires_in\":3600,\"token_type\":\"Bearer\"}",
        headers: [],
        status: 200
      }
      {:ok, token} = Token.from_response(response, "some@account.com", "some_scope")

      assert %Token{} = token
    end

    test "tokens can be built from HTTPact.Responses with delegated authorities" do
      response = %HTTPact.Response{
        body: "{\"access_token\":\"some_access_token\",\"expires_in\":3600,\"token_type\":\"Bearer\"}",
        headers: [],
        status: 200
      }
      {:ok, token} = Token.from_response(response, "some@account.com", "some_scope", "authority@account.com")

      assert %Token{} = token
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

  describe "token fetching:" do
    setup _ do
      decoded_creds = %{
        "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
        "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
        "client_email" => "test@test.com",
        "client_id" => "some_sequence_of_integers",
        "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/test-test%40test-auth.iam.gserviceaccount.com",
        "private_key" => "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCN1IUO2QhgdI+Q\nUTIWV9X7Gm9Cw6kPgHeZ+f+RXXknSL6/CAwVz1EG2VIgCBJv45mF0Vsw2vM8/0Sx\nSDoEb7skelCahYCQUOIp72egAk3InOINGo/n+A1ai7fmR0EzQ6WFr3pZmzcX/7ZB\n0TjDkXX81NJIreJSfqSCvMg7uZfzihv7RbmljyofxoXwP8FoMOS5BcHo8ZkBZyJx\ny0uLKrFvCkTRS/OhuGRVcJC6VrZUA2MhQPkqjHNcttEXIajL+jl4jmVQ8irwR4LO\nXnFaBoEXexciTAteO4vjrrV2iIh0x24vgD2SemhUW/pOTZ/AMNUjwjnvmWFdvvyf\nFYDTtHL1AgMBAAECggEBAILyYBchUpabh6EbFj+CwVGhSnA97e0eE07afpdb0evv\nQg1mBKJuUsUcCLMCQOOFI81lSeiFfmYm2OlFYiuObR50v86qy9RymR1WqDoXZnF+\nR0cJ6yuk3c9niFbYGt6V6lDPfwsUP32s3j1OSjZmKqVQaQYpZPf9bS431jcuV5jF\n0tJEFZTY+FS3BW3JefpDCBW1SmyXtA4BiZdP37I9hKOohC7iQuOna5g9iaCbFKC4\nw80FZngDB4MTpSypjYBOR4SROOcIMd3cXyDJEuYoJqKpc3Ke9QZrHPSZPKREug7u\nG7v5TwFXwn2lLtlV7KXAknl2CUNGHEzDOyMRP0PVZtECgYEA9ywGoPFP2ejMVJ+e\nvsSo5x5mXL0hczYyUT1ryohi1+4Rq4S4StfvLKZ9hKp8xzOOwChV0QNT6ZdLTOQo\nSQWQ0tqZfzIVOBFxeqRPokaojQ0MEvXcDTnUzCSh7q+GvNFkN5kMcOCaPYGsCWzU\np/BYjyijX/SB3Y/vWCIlRWQpQx8CgYEAkuVRtn5nOwlWcykRE/PYZo9HNPcjdW2Q\nAIki1ntfHZTikLRf3cRpWYgWqbYJMiTq4Mkwhye0jgKRVs8urHJwVxYTXyfPl6UM\n17DaCwnX2VuMDEM9cbBxF4MdbIBuQ7YJUmajrh63E/hx2NJso6/nvYk5V4v5v5lZ\nwTKB+7+a+2sCgYEAoWeSfI6YAkhPBgOl+hUZ5rKnTXAD4+REP2DIft1JDpBb4ZEt\nd1JC0Pl3haZ/DOXSFhFA2Ng/d45gkbl7xRNpWwd8rN7blF1vqRKbHfDeKB2ZANij\n9c8J8rUJOYBNkAd8VgIPabaBgiCnYxA6XeBJNFLpPMPB+hj/xqGljQa3GykCgYAo\nLyNTUPDcbYmAp1NMqgAgzkEkdBb3IKmr+9fT5Jv4c6om+7Dd8cUAAQJyGqIZXZAD\nPgZQcsQptPodTT/vXL7uk9NozHM1gKkqt+5t5pttkmWVVS+R0jqdu/honhmL3Fhg\nekN8dlqO1AAQ2D9v58b1SnytPlVr3H95Il/8hkXXUQKBgDvylw5n2rW4ER2j91Lg\nW74L2D9VXIFp8Trrb+QE5G87GQDXq+WaixEScC0tdOV1MnOHQFRLbMzXQcuf34uu\nLu1yTECyOrRwI2tDcCCnNXQx+e10lGhf8sbWTR9jNjWX5QIBiGdOIq7CV8174IuH\nI7pFKB+yxZJd4tT/F4IbrUBU\n-----END PRIVATE KEY-----\n",
        "private_key_id" => "private_key_id",
        "project_id" => "test-test",
        "token_uri" => "https://oauth2.googleapis.com/token",
        "type" => "service_account"
      }
      {:ok, credentials} = Credentials.new(decoded_creds)

      {:ok, %{credentials: credentials}}
    end

    test "OAuth tokens for service accounts", %{credentials: credentials} do
      {:ok, token} = Gauthic.token_for_scope(credentials,
        "https://www.googleapis.com/auth/admin.directory.user",
        http_client: GoogleAuthMock
      )
      assert %Token{} = token
    end

    test "OAuth tokens for service accounts and a delegated authority", %{credentials: credentials} do
      {:ok, token} =
        Gauthic.token_for_scope(credentials,
          "https://www.googleapis.com/auth/admin.directory.user",
          "sub@sub.com",
          http_client: GoogleAuthMock
        )
      assert %Token{} = token
    end

    test "we can get google compute tokens" do
      assert false
    end

    test "we can get refresh tokens" do
      assert false
    end
  end
end
