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

-module(b64url_tests).

-include_lib("eunit/include/eunit.hrl").

encode_without_padding_test_() ->
  [?_assertEqual(<<>>,
                 b64url:encode(<<>>, [nopad])),
   ?_assertEqual(<<"Zg">>,
                 b64url:encode(<<"f">>, [nopad])),
   ?_assertEqual(<<"Zm8">>,
                 b64url:encode(<<"fo">>, [nopad])),
   ?_assertEqual(<<"Zm9v">>,
                 b64url:encode(<<"foo">>, [nopad])),
   ?_assertEqual(<<"Zm9vYg">>,
                 b64url:encode(<<"foob">>, [nopad])),
   ?_assertEqual(<<"Zm9vYmE">>,
                 b64url:encode(<<"fooba">>, [nopad])),
   ?_assertEqual(<<"Zm9vYmFy">>,
                 b64url:encode(<<"foobar">>, [nopad]))].

encode_with_padding_test_() ->
  [?_assertEqual(<<>>,
                 b64url:encode(<<>>)),
   ?_assertEqual(<<"Zg==">>,
                 b64url:encode(<<"f">>)),
   ?_assertEqual(<<"Zm8=">>,
                 b64url:encode(<<"fo">>)),
   ?_assertEqual(<<"Zm9v">>,
                 b64url:encode(<<"foo">>)),
   ?_assertEqual(<<"Zm9vYg==">>,
                 b64url:encode(<<"foob">>)),
   ?_assertEqual(<<"Zm9vYmE=">>,
                 b64url:encode(<<"fooba">>)),
   ?_assertEqual(<<"Zm9vYmFy">>,
                 b64url:encode(<<"foobar">>))].

decode_without_padding_test_() ->
  [?_assertEqual({ok, <<>>},
                 b64url:decode(<<>>, [nopad])),
   ?_assertEqual({ok, <<"f">>},
                 b64url:decode(<<"Zg">>, [nopad])),
   ?_assertEqual({ok, <<"fo">>},
                 b64url:decode(<<"Zm8">>, [nopad])),
   ?_assertEqual({ok, <<"foo">>},
                 b64url:decode(<<"Zm9v">>, [nopad])),
   ?_assertEqual({ok, <<"foob">>},
                 b64url:decode(<<"Zm9vYg">>, [nopad])),
   ?_assertEqual({ok, <<"fooba">>},
                 b64url:decode(<<"Zm9vYmE">>, [nopad])),
   ?_assertEqual({ok, <<"foobar">>},
                 b64url:decode(<<"Zm9vYmFy">>, [nopad])),
   ?_assertEqual({error, {invalid_data, <<"!">>}},
                 b64url:decode(<<"!">>, [nopad])),
   ?_assertEqual({error, {invalid_base64_char, 33}},
                 b64url:decode(<<"a!">>, [nopad])),
   ?_assertEqual({error, invalid_encoding},
                 b64url:decode(<<"Zg==">>, [nopad]))].

decode_with_padding_test_() ->
  [?_assertEqual({ok, <<>>},
                 b64url:decode(<<>>)),
   ?_assertEqual({ok, <<"f">>},
                 b64url:decode(<<"Zg==">>)),
   ?_assertEqual({ok, <<"fo">>},
                 b64url:decode(<<"Zm8=">>)),
   ?_assertEqual({ok, <<"foo">>},
                 b64url:decode(<<"Zm9v">>)),
   ?_assertEqual({ok, <<"foob">>},
                 b64url:decode(<<"Zm9vYg==">>)),
   ?_assertEqual({ok, <<"fooba">>},
                 b64url:decode(<<"Zm9vYmE=">>)),
   ?_assertEqual({ok, <<"foobar">>},
                 b64url:decode(<<"Zm9vYmFy">>)),
   ?_assertEqual({error, {invalid_data, <<"!">>}},
                 b64url:decode(<<"!">>)),
   ?_assertEqual({error, {invalid_base64_char, 36}},
                 b64url:decode(<<"ZjA$">>))].
