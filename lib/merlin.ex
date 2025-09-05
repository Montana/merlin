defmodule Merlin do

  @type pw_opts :: %{length: pos_integer(), symbols?: boolean()}

  @spec uuid4() :: String.t()
  def uuid4 do
    <<u0::32, u1::16, raw2::16, raw3::16, u4::48>> = :crypto.strong_rand_bytes(16)
    u2 = (raw2 &&& 0x0fff) ||| 0x4000
    u3 = (raw3 &&& 0x3fff) ||| 0x8000

    :io_lib.format("~8.16.0b-~4.16.0b-~4.16.0b-~4.16.0b-~12.16.0b",
      [u0, u1, u2, u3, u4]
    )
    |> to_string()
  end

  import Bitwise

  @spec random_password(pw_opts()) :: String.t()
  def random_password(opts \\ %{length: 16, symbols?: false}) do
    len = Map.get(opts, :length, 16)
    symbols? = Map.get(opts, :symbols?, false)

    lowers = Enum.to_list(?a..?z)
    uppers = Enum.to_list(?A..?Z)
    digits = Enum.to_list(?0..?9)
    symbols = '!-_@$%^&*+=?~'

    pool = (lowers ++ uppers ++ digits) ++ if(symbols?, do: symbols, else: [])

    pool_size = length(pool)

    1..len
    |> Enum.map(fn _ ->
      <<n::32>> = :crypto.strong_rand_bytes(4)
      Enum.at(pool, rem(n, pool_size))
    end)
    |> to_string()
  end

  @spec pretty_json(binary() | map()) :: String.t()
  def pretty_json(input) when is_binary(input) do
    case Jason.decode(input) do
      {:ok, data} -> pretty_json(data)
      {:error, err} -> raise ArgumentError, message: "Invalid JSON: #{inspect(err)}"
    end
  end

  def pretty_json(input) when is_map(input) or is_list(input) do
    Jason.encode!(input, pretty: true)
  end

  @spec sum([number()]) :: number()
  def sum(nums) when is_list(nums), do: Enum.reduce(nums, 0, &+/2)

  @spec base64_encode(String.t()) :: String.t()
  def base64_encode(input) do
    Base.encode64(input)
  end

  @spec base64_decode(String.t()) :: String.t()
  def base64_decode(input) do
    case Base.decode64(input) do
      {:ok, decoded} -> decoded
      :error -> raise ArgumentError, "Invalid base64 input"
    end
  end

  @spec md5(String.t()) :: String.t()
  def md5(input) do
    :crypto.hash(:md5, input) |> Base.encode16(case: :lower)
  end

  @spec sha1(String.t()) :: String.t()
  def sha1(input) do
    :crypto.hash(:sha, input) |> Base.encode16(case: :lower)
  end

  @spec sha256(String.t()) :: String.t()
  def sha256(input) do
    :crypto.hash(:sha256, input) |> Base.encode16(case: :lower)
  end

  @spec word_count(String.t()) :: non_neg_integer()
  def word_count(text) do
    text
    |> String.split()
    |> length()
  end

  @spec line_count(String.t()) :: non_neg_integer()
  def line_count(text) do
    text
    |> String.split("\n")
    |> length()
  end

  @spec reverse(String.t()) :: String.t()
  def reverse(text) do
    text |> String.reverse()
  end

  @spec timestamp() :: String.t()
  def timestamp do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  @spec timestamp_unix() :: integer()
  def timestamp_unix do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  @spec format_date(String.t(), String.t()) :: String.t()
  def format_date(date_string, format \\ "%Y-%m-%d %H:%M:%S") do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _} ->
        Calendar.strftime(datetime, format)
      {:error, _} ->
        case Date.from_iso8601(date_string) do
          {:ok, date} ->
            Calendar.strftime(date, format)
          {:error, _} ->
            raise ArgumentError, "Invalid date format"
        end
    end
  end

  @spec file_checksum(String.t()) :: String.t()
  def file_checksum(file_path) do
    file_path
    |> File.read!()
    |> sha256()
  end

  @spec file_info(String.t()) :: map()
  def file_info(file_path) do
    case File.stat(file_path) do
      {:ok, stat} ->
        %{
          size: stat.size,
          type: if(stat.type == :regular, do: "file", else: "directory"),
          permissions: stat.mode,
          modified: DateTime.from_unix!(stat.mtime),
          accessed: DateTime.from_unix!(stat.atime)
        }
      {:error, reason} ->
        raise File.Error, reason: reason, action: "read file info", path: file_path
    end
  end

  @spec list_directory(String.t()) :: [map()]
  def list_directory(path \\ ".") do
    path
    |> File.ls!()
    |> Enum.map(fn name ->
      full_path = Path.join(path, name)
      stat = File.stat!(full_path)
      
      %{
        name: name,
        type: if(stat.type == :regular, do: "file", else: "directory"),
        size: stat.size,
        permissions: format_permissions(stat.mode),
        modified: DateTime.from_unix!(stat.mtime) |> DateTime.to_date() |> Date.to_string(),
        accessed: DateTime.from_unix!(stat.atime) |> DateTime.to_date() |> Date.to_string()
      }
    end)
    |> Enum.sort_by(fn item -> {item.type, item.name} end)
  end

  @spec format_permissions(integer()) :: String.t()
  defp format_permissions(mode) do
    permissions = [
      if(mode &&& 0o400 != 0, do: "r", else: "-"),
      if(mode &&& 0o200 != 0, do: "w", else: "-"),
      if(mode &&& 0o100 != 0, do: "x", else: "-"),
      if(mode &&& 0o040 != 0, do: "r", else: "-"),
      if(mode &&& 0o020 != 0, do: "w", else: "-"),
      if(mode &&& 0o010 != 0, do: "x", else: "-"),
      if(mode &&& 0o004 != 0, do: "r", else: "-"),
      if(mode &&& 0o002 != 0, do: "w", else: "-"),
      if(mode &&& 0o001 != 0, do: "x", else: "-")
    ]
    |> Enum.join()
  end

  @spec format_size(integer()) :: String.t()
  def format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  def format_size(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  def format_size(bytes) when bytes < 1024 * 1024 * 1024, do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"
  def format_size(bytes), do: "#{Float.round(bytes / (1024 * 1024 * 1024), 1)} GB"

  @spec format_table([map()], [atom()]) :: String.t()
  def format_table(rows, columns) when length(rows) == 0, do: "No items found"
  
  def format_table(rows, columns) do
    widths = 
      columns
      |> Enum.map(fn col ->
        max_width = 
          rows
          |> Enum.map(fn row -> 
            value = Map.get(row, col, "")
            String.length(to_string(value))
          end)
          |> Enum.max()
        
        max(max_width, String.length(Atom.to_string(col)))
      end)

    header = 
      columns
      |> Enum.with_index()
      |> Enum.map(fn {col, idx} ->
        String.pad_trailing(Atom.to_string(col), Enum.at(widths, idx))
      end)
      |> Enum.join(" | ")

    separator = 
      widths
      |> Enum.map(fn width -> String.duplicate("-", width) end)
      |> Enum.join("-+-")

    formatted_rows = 
      rows
      |> Enum.map(fn row ->
        columns
        |> Enum.with_index()
        |> Enum.map(fn {col, idx} ->
          value = Map.get(row, col, "")
          String.pad_trailing(to_string(value), Enum.at(widths, idx))
        end)
        |> Enum.join(" | ")
      end)

    [header, separator | formatted_rows]
    |> Enum.join("\n")
  end

  @spec filesystem_table(String.t()) :: String.t()
  def filesystem_table(path \\ ".") do
    path
    |> list_directory()
    |> Enum.map(fn item ->
      Map.put(item, :size_formatted, format_size(item.size))
    end)
    |> format_table([:name, :type, :size_formatted, :permissions, :modified])
  end

  @spec disk_usage(String.t()) :: map()
  def disk_usage(path \\ ".") do
    case :filelib.is_dir(path) do
      true ->
        {total_size, file_count, dir_count} = calculate_directory_size(path)
        %{
          path: path,
          total_size: total_size,
          total_size_formatted: format_size(total_size),
          file_count: file_count,
          directory_count: dir_count,
          total_items: file_count + dir_count
        }
      false ->
        raise ArgumentError, "Path does not exist or is not a directory: #{path}"
    end
  end

  @spec calculate_directory_size(String.t()) :: {integer(), integer(), integer()}
  defp calculate_directory_size(path) do
    path
    |> File.ls!()
    |> Enum.reduce({0, 0, 0}, fn name, {total_size, file_count, dir_count} ->
      full_path = Path.join(path, name)
      stat = File.stat!(full_path)
      
      case stat.type do
        :regular ->
          {total_size + stat.size, file_count + 1, dir_count}
        :directory ->
          {sub_size, sub_files, sub_dirs} = calculate_directory_size(full_path)
          {total_size + sub_size, file_count + sub_files, dir_count + sub_dirs + 1}
      end
    end)
  end

  @spec find_files(String.t(), String.t()) :: [String.t()]
  def find_files(directory, pattern) do
    directory
    |> File.ls!()
    |> Enum.flat_map(fn name ->
      full_path = Path.join(directory, name)
      stat = File.stat!(full_path)
      
      case stat.type do
        :regular ->
          if String.contains?(name, pattern), do: [full_path], else: []
        :directory ->
          find_files(full_path, pattern)
      end
    end)
  end
end
