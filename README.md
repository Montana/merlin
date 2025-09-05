# merlin

a lightweight command-line utility built in elixir that provides essential tools for developers: uuid generation, password creation, json formatting, text processing, hashing, encoding, time utilities, and filesystem operations with beautiful table formatting.

## installation

requires elixir >= 1.15

```bash
cd merlin
mix deps.get
mix escript.build
./merlin help
```

## commands

### basic commands
- `merlin hello NAME` - greet someone
- `merlin uuid` - generate uuid v4
- `merlin gen password [-l N] [--symbols]` - generate random password
- `merlin json pretty < input.json` - pretty-print json from stdin
- `merlin sum 1 2 3.5` - sum numbers

### encoding/decoding
- `merlin base64 encode < input` - base64 encode from stdin
- `merlin base64 decode < input` - base64 decode from stdin

### hashing
- `merlin hash md5 < input` - md5 hash from stdin
- `merlin hash sha1 < input` - sha1 hash from stdin
- `merlin hash sha256 < input` - sha256 hash from stdin

### text utilities
- `merlin text words < input` - count words from stdin
- `merlin text lines < input` - count lines from stdin
- `merlin text reverse < input` - reverse text from stdin

### time utilities
- `merlin time now` - current iso timestamp
- `merlin time unix` - current unix timestamp
- `merlin time format DATE` - format date (iso format)
- `merlin time format DATE FORMAT` - format date with custom format

### file operations
- `merlin file checksum FILE` - sha256 checksum of file
- `merlin file info FILE` - file information (json)

### filesystem table
- `merlin fs list` - list current directory in table format
- `merlin fs list PATH` - list specified directory in table format
- `merlin fs usage` - show disk usage for current directory
- `merlin fs usage PATH` - show disk usage for specified directory
- `merlin fs find PATTERN` - find files matching pattern in current dir
- `merlin fs find DIR PATTERN` - find files matching pattern in directory

## options

- `-l, --length N` - password length (default: 16)
- `--symbols` - include symbols in password

## examples

```bash
./merlin hello michael
./merlin uuid
./merlin gen password -l 20 --symbols
cat payload.json | ./merlin json pretty
./merlin sum 10 20 30.5
echo "hello" | ./merlin base64 encode
echo "agvsbg8=" | ./merlin base64 decode
echo "hello world" | ./merlin hash sha256
echo "hello\nworld" | ./merlin text lines
./merlin time now
./merlin file checksum readme.md
./merlin fs list
./merlin fs usage lib/
./merlin fs find "*.ex"
```

## features

- password generation with customizable length and symbols
- uuid v4 generation
- filesystem table listings with disk usage analysis
- file search and information display
- text utilities (word count, line count, reverse)
- time and date formatting
- hashing (md5, sha1, sha256) and base64 encoding/decoding
- json pretty-printing
- mathematical operations

## author
michael mendy (c) 2025
