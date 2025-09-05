defmodule Merlin.CLI do

  def main(argv) do
    case argv do
      ["help"] -> usage()
      ["--help"] -> usage()
      ["-h"] -> usage()

      ["hello", name] ->
        IO.puts("✨ Merlin: Hello, #{name}!"); :ok

      ["uuid"] ->
        IO.puts(Merlin.uuid4())

      ["gen", "password" | rest] ->
        {opts, _, _} =
          OptionParser.parse(rest,
            switches: [length: :integer, symbols: :boolean],
            aliases: [l: :length, s: :symbols]
          )

        length = Keyword.get(opts, :length, 16)
        symbols? = Keyword.get(opts, :symbols, false)

        IO.puts(Merlin.random_password(%{length: length, symbols?: symbols?}))

      ["json", "pretty"] ->
        input = IO.read(:stdio, :all)
        IO.puts(Merlin.pretty_json(input))

      ["sum" | nums] when length(nums) > 0 ->
        numbers =
          Enum.map(nums, fn s ->
            case Float.parse(s) do
              {f, ""} -> f
              _ -> raise ArgumentError, "Not a number: #{s}"
            end
          end)

        IO.puts(numbers |> Merlin.sum() |> to_string())

      ["base64", "encode"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.base64_encode(input))

      ["base64", "decode"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.base64_decode(input))

      ["hash", "md5"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.md5(input))

      ["hash", "sha1"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.sha1(input))

      ["hash", "sha256"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.sha256(input))

      ["text", "words"] ->
        input = IO.read(:stdio, :all)
        IO.puts(Merlin.word_count(input) |> to_string())

      ["text", "lines"] ->
        input = IO.read(:stdio, :all)
        IO.puts(Merlin.line_count(input) |> to_string())

      ["text", "reverse"] ->
        input = IO.read(:stdio, :all) |> String.trim()
        IO.puts(Merlin.reverse(input))

      ["time", "now"] ->
        IO.puts(Merlin.timestamp())

      ["time", "unix"] ->
        IO.puts(Merlin.timestamp_unix() |> to_string())

      ["time", "format", date_string] ->
        IO.puts(Merlin.format_date(date_string))

      ["time", "format", date_string, format] ->
        IO.puts(Merlin.format_date(date_string, format))

      ["file", "checksum", file_path] ->
        IO.puts(Merlin.file_checksum(file_path))

      ["file", "info", file_path] ->
        info = Merlin.file_info(file_path)
        IO.puts(Merlin.pretty_json(info))

      ["fs", "list"] ->
        IO.puts(Merlin.filesystem_table())

      ["fs", "list", path] ->
        IO.puts(Merlin.filesystem_table(path))

      ["fs", "usage"] ->
        usage_info = Merlin.disk_usage()
        IO.puts(Merlin.pretty_json(usage_info))

      ["fs", "usage", path] ->
        usage_info = Merlin.disk_usage(path)
        IO.puts(Merlin.pretty_json(usage_info))

      ["fs", "find", pattern] ->
        files = Merlin.find_files(".", pattern)
        files |> Enum.each(&IO.puts/1)

      ["fs", "find", directory, pattern] ->
        files = Merlin.find_files(directory, pattern)
        files |> Enum.each(&IO.puts/1)

      _ ->
        usage()
        System.halt(1)
    end
  end

  defp usage do
    IO.puts ~S"""
    Merlin — a tiny Elixir CLI ✨

    Basic Commands:
      merlin hello NAME
      merlin uuid
      merlin gen password [-l N] [--symbols]
      merlin json pretty < input.json
      merlin sum 1 2 3.5

    Encoding/Decoding:
      merlin base64 encode < input
      merlin base64 decode < input

    Hashing:
      merlin hash md5 < input
      merlin hash sha1 < input
      merlin hash sha256 < input

    Text Utilities:
      merlin text words < input
      merlin text lines < input
      merlin text reverse < input

    Time Utilities:
      merlin time now
      merlin time unix
      merlin time format DATE
      merlin time format DATE FORMAT

    File Operations:
      merlin file checksum FILE
      merlin file info FILE

    Filesystem Table:
      merlin fs list
      merlin fs list PATH
      merlin fs usage
      merlin fs usage PATH
      merlin fs find PATTERN
      merlin fs find DIR PATTERN

    Options:
      -l, --length N     password length (default: 16)
          --symbols      include symbols in password

    Examples:
      merlin hello Michael
      merlin uuid
      merlin gen password -l 20 --symbols
      cat payload.json | merlin json pretty
      merlin sum 10 20 30.5
      echo "hello" | merlin base64 encode
      echo "aGVsbG8=" | merlin base64 decode
      echo "hello world" | merlin hash sha256
      echo "hello\nworld" | merlin text lines
      merlin time now
      merlin file checksum README.md
      merlin fs list
      merlin fs usage lib/
      merlin fs find "*.ex"
    """
  end
end
