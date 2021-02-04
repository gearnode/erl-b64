%% Copyright (c) 2021 Bryan Frimin <bryan@frimin.fr>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
%% IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(b64url).

-export([encode/1, encode/2,
         decode/1, decode/2]).

-spec encode(binary()) -> binary().
encode(Bin) when is_binary(Bin) ->
  encode(Bin, []).

-spec encode(binary(), Options) -> binary() when
    Options :: [Option],
    Option :: nopad.
encode(Bin, Options) when is_binary(Bin), is_list(Options) ->
  case proplists:get_bool(nopad, Options) of
    true ->
      encode(nopad, Bin, <<>>);
    false ->
      encode(pad, Bin, <<>>)
  end.

-spec encode(pad | nopad, binary(), binary()) -> binary().
encode(_Mode, <<>>, Acc) ->
  Acc;
encode(Mode, <<A0:6, B0:6, C0:6, D0:6, Rest/binary>>, Acc) ->
  A = dec_base64_digit(A0),
  B = dec_base64_digit(B0),
  C = dec_base64_digit(C0),
  D = dec_base64_digit(D0),
  encode(Mode, Rest, <<Acc/binary, A, B, C, D>>);
encode(nopad, <<A0:6, B0:2>>, Acc) ->
  A = dec_base64_digit(A0),
  B = dec_base64_digit(B0 bsl 4),
  encode(nopad, <<>>, <<Acc/binary, A, B>>);
encode(nopad, <<A0:6, B0:6, C0:4>>, Acc) ->
  A = dec_base64_digit(A0),
  B = dec_base64_digit(B0),
  C = dec_base64_digit(C0 bsl 2),
  encode(nopad, <<>>, <<Acc/binary, A, B, C>>);
encode(pad, <<A0:6, B0:2>>, Acc) ->
  A = dec_base64_digit(A0),
  B = dec_base64_digit(B0 bsl 4),
  encode(pad, <<>>, <<Acc/binary, A, B, $=, $=>>);
encode(pad, <<A0:6, B0:6, C0:4>>, Acc) ->
  A = dec_base64_digit(A0),
  B = dec_base64_digit(B0),
  C = dec_base64_digit(C0 bsl 2),
  encode(pad, <<>>, <<Acc/binary, A, B, C, $=>>).

-spec dec_base64_digit(0..63) ->
        $A..$Z | $a..$z | $0..$9 | $- | $_.
dec_base64_digit(Char) when Char =< 25 ->
  Char + $A;
dec_base64_digit(Char) when Char =< 51 ->
  Char + $a - 26;
dec_base64_digit(Char) when Char =< 61 ->
  Char + $0 - 52;
dec_base64_digit(62) ->
  $-;
dec_base64_digit(63) ->
  $_.

-spec decode(binary()) ->
        {ok, binary()} | {error, term()}.
decode(Bin) when is_binary(Bin) ->
  decode(Bin, []).

-spec decode(binary(), Options) ->
        {ok, binary()} | {error, term()} when
    Options :: [Option],
    Option :: nopad.
decode(Bin, Options) when is_binary(Bin), is_list(Options) ->
  try
    case proplists:get_bool(nopad, Options) of
      true ->
        decode(nopad, Bin, <<>>);
      false ->
        decode(pad, Bin, <<>>)
    end
  catch
    throw:{error, Reason} ->
      {error, Reason}
  end.

-spec decode(pad | nopad, binary(), binary()) ->
        {ok, binary()} | {error, term()}.
decode(_Mode, <<>>, Acc) ->
  {ok, Acc};
decode(nopad, <<_A:8, _B:8, _C:8, $=:8>>, _Acc) ->
  {error, invalid_encoding};
decode(nopad, <<_A:8, _B:8, $=:8, $=:8>>, _Acc) ->
  {error, invalid_encoding};
decode(nopad, <<A0:8, B0:8, C0:8>>, Acc) ->
  A = dec_base64_char(A0),
  B = dec_base64_char(B0),
  C = dec_base64_char(C0) bsr 2,
  decode(nopad, <<>>, <<Acc/binary, A:6, B:6, C:4>>);
decode(nopad, <<A0:8, B0:8>>, Acc) ->
  A = dec_base64_char(A0),
  B = dec_base64_char(B0) bsr 4,
  decode(nopad, <<>>, <<Acc/binary, A:6, B:2>>);
decode(pad, <<A0:8, B0:8, $=:8, $=:8>>, Acc) ->
  A = dec_base64_char(A0),
  B = dec_base64_char(B0) bsr 4,
  decode(pad, <<>>, <<Acc/binary, A:6, B:2>>);
decode(pad, <<A0:8, B0:8, C0:8, $=:8>>, Acc) ->
  A = dec_base64_char(A0),
  B = dec_base64_char(B0),
  C = dec_base64_char(C0) bsr 2,
  decode(pad, <<>>, <<Acc/binary, A:6, B:6, C:4>>);
decode(Mode, <<A0:8, B0:8, C0:8, D0:8, Rest/binary>>, Acc) ->
  A = dec_base64_char(A0),
  B = dec_base64_char(B0),
  C = dec_base64_char(C0),
  D = dec_base64_char(D0),
  decode(Mode, Rest, <<Acc/binary, A:6, B:6, C:6, D:6>>);
decode(_Mode, Data, _Acc) ->
  {error, {invalid_data, Data}}.

-spec dec_base64_char($A..$Z | $a..$z | $0..$9 | $- | $_) ->
        0..63.
dec_base64_char(Char) when Char >= $A, Char =< $Z ->
  Char - $A;
dec_base64_char(Char) when Char >= $a, Char =< $z ->
  Char - $a + 26;
dec_base64_char(Char) when Char >= $0, Char =< $9 ->
  Char - $0 + 52;
dec_base64_char($-) ->
  62;
dec_base64_char($_) ->
  63;
dec_base64_char(Char) ->
  throw({error, {invalid_base64_char, Char}}).
