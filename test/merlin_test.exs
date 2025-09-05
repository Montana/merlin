defmodule MerlinTest do
  use ExUnit.Case, async: true

  test "uuid4 generates a well-formed UUID" do
    uuid = Merlin.uuid4()
    assert String.length(uuid) == 36
    assert String.at(uuid, 14) == "4"
    assert String.at(uuid, 19) in ["8", "9", "a", "b"]
  end

  test "random_password default length" do
    pw = Merlin.random_password()
    assert String.length(pw) == 16
  end

  test "sum" do
    assert Merlin.sum([1, 2, 3.5]) == 6.5
  end

  test "base64 encode/decode" do
    input = "hello world"
    encoded = Merlin.base64_encode(input)
    decoded = Merlin.base64_decode(encoded)
    assert decoded == input
  end

  test "hash functions" do
    input = "test"
    md5_hash = Merlin.md5(input)
    sha1_hash = Merlin.sha1(input)
    sha256_hash = Merlin.sha256(input)
    
    assert String.length(md5_hash) == 32
    assert String.length(sha1_hash) == 40
    assert String.length(sha256_hash) == 64
  end

  test "text utilities" do
    text = "hello world\nthis is a test"
    assert Merlin.word_count(text) == 6
    assert Merlin.line_count(text) == 2
    assert Merlin.reverse("hello") == "olleh"
  end

  test "format size" do
    assert Merlin.format_size(512) == "512 B"
    assert Merlin.format_size(1536) == "1.5 KB"
    assert Merlin.format_size(1048576) == "1.0 MB"
  end

  test "filesystem table" do
    result = Merlin.filesystem_table()
    assert is_binary(result)
    assert String.contains?(result, "name")
    assert String.contains?(result, "type")
  end

  test "disk usage" do
    usage = Merlin.disk_usage(".")
    assert Map.has_key?(usage, :path)
    assert Map.has_key?(usage, :total_size)
    assert Map.has_key?(usage, :file_count)
    assert Map.has_key?(usage, :directory_count)
  end
end
