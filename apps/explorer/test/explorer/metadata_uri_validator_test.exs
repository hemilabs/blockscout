defmodule Explorer.MetadataURIValidatorTest do
  use ExUnit.Case, async: false

  alias Explorer.MetadataURIValidator

  setup do
    :persistent_term.erase(:parsed_cidr_list)

    prev_env = Application.fetch_env(:indexer, Indexer.Fetcher.TokenInstance.Helper)

    Application.put_env(:indexer, Indexer.Fetcher.TokenInstance.Helper,
      cidr_blacklist: [],
      allowed_uri_protocols: ["http", "https"]
    )

    on_exit(fn ->
      :persistent_term.erase(:parsed_cidr_list)

      case prev_env do
        {:ok, value} -> Application.put_env(:indexer, Indexer.Fetcher.TokenInstance.Helper, value)
        :error -> Application.delete_env(:indexer, Indexer.Fetcher.TokenInstance.Helper)
      end
    end)

    :ok
  end

  describe "validate_uri/1 blocks IPv6-mapped IPv4 addresses" do
    test "blocks ::ffff:127.0.0.1 (IPv6-mapped loopback)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::ffff:127.0.0.1]:4000/api")
    end

    test "blocks ::ffff:10.0.0.1 (IPv6-mapped private)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::ffff:10.0.0.1]/metadata")
    end

    test "blocks ::ffff:192.168.1.1 (IPv6-mapped private)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::ffff:192.168.1.1]/token")
    end

    test "blocks ::ffff:169.254.0.1 (IPv6-mapped link-local)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::ffff:169.254.0.1]/")
    end

    test "blocks ::ffff:172.16.0.1 (IPv6-mapped private)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::ffff:172.16.0.1]/")
    end
  end

  describe "validate_uri/1 blocks native IPv6 reserved addresses" do
    test "blocks ::1 (IPv6 loopback)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[::1]:4000/api")
    end

    test "blocks fe80::1 (link-local)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[fe80::1]/")
    end

    test "blocks fc00::1 (unique local address)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[fc00::1]/")
    end

    test "blocks fd00::1 (unique local address)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[fd00::1]/")
    end

    test "blocks 2001:db8::1 (documentation)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://[2001:db8::1]/")
    end
  end

  describe "validate_uri/1 blocks IPv4 reserved addresses" do
    test "blocks 127.0.0.1 (loopback)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://127.0.0.1:4000/api")
    end

    test "blocks 10.0.0.1 (private)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://10.0.0.1/metadata")
    end

    test "blocks 192.168.1.1 (private)" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://192.168.1.1/")
    end

    test "blocks 0.0.0.0" do
      assert {:error, :blacklist} = MetadataURIValidator.validate_uri("http://0.0.0.0/")
    end
  end

  describe "validate_uri/1 allows valid public addresses" do
    test "allows a public IPv4 address" do
      # 8.8.8.8 is a public IP literal — resolved via :inet.parse_address/1, no DNS lookup
      assert :ok = MetadataURIValidator.validate_uri("http://8.8.8.8/metadata.json")
    end

    test "allows a public IPv6 address" do
      # 2600:: is in the public range
      assert :ok = MetadataURIValidator.validate_uri("http://[2600::1]/metadata.json")
    end
  end

  describe "validate_uri/1 rejects invalid URIs" do
    test "rejects empty host" do
      assert {:error, :empty_host} = MetadataURIValidator.validate_uri("not_a_uri")
    end

    test "rejects disallowed protocol" do
      assert {:error, :disallowed_protocol} = MetadataURIValidator.validate_uri("ftp://example.com/file")
    end
  end
end
