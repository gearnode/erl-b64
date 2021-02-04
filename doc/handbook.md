# Introduction
This document contains development notes about the `b64` library.

# Versioning
The following `b64` versions are available:
- `0.y.z` unstable versions.
- `x.y.z` stable versions: `b64` will maintain reasonable backward
  compatibility, deprecating features before removing them.
- Experimental untagged versions.

Developers who use unstable or experimental versions are responsible for
updating their application when `b64` is modified. Note that unstable
versions can be modified without backward compatibility at any time.

# Modules
## `b64`
### `encode/1`
Encodes a binary into a base64 encoded binary.

Same as `encode(Bin, [])`.

### `encode/2`
Encodes a binary into a base64 encoded binary.

Example:
```erlang
b64:encode(<<"foo">>, [nopad]).
```
### `decode/1`
Decodes a base64 encoded binary into a binary.

Same as `decode(Bin, [])`.

### `decode/2`
Decodes a base64 encoded binary into a binary.

Example:
```erlang
{ok, Bin} = b64:decode(<<"Zg">>, [nopad]).
```

## `b64url`
Encodes a binary into a base64 url encoded binary.

Same as `encode(Bin, [])`.

### `encode/2`
Encodes a binary into a base64 url encoded binary.

Example:
```erlang
b64url:encode(<<"foo">>, [nopad]).
```
### `decode/1`
Decodes a base64 url encoded binary into a binary.

Same as `decode(Bin, [])`.

### `decode/2`
Decodes a base64 url encoded binary into a binary.

Example:
```erlang
{ok, Bin} = b64url:decode(<<"Zg">>, [nopad]).
```
