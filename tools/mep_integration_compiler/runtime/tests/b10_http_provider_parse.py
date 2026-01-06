# -*- coding: utf-8 -*-
from __future__ import annotations

import json

from tools.mep_integration_compiler.runtime.adapters.http_header_provider import parse_headers_response


def main() -> None:
    # Simple
    hs = parse_headers_response({"headers": ["a", "b", "c"]})
    assert hs == ["a", "b", "c"]

    # With ok
    hs = parse_headers_response({"ok": True, "headers": ["x", "y"]})
    assert hs == ["x", "y"]

    # Nested
    hs = parse_headers_response({"data": {"headers": ["m", "n"]}})
    assert hs == ["m", "n"]

    # String input
    hs = parse_headers_response('{"headers":["p","q"]}')
    assert hs == ["p", "q"]

    # Bad
    try:
        parse_headers_response({"headerz": []})
        raise AssertionError("expected failure")
    except ValueError:
        pass

    try:
        parse_headers_response({"headers": "nope"})
        raise AssertionError("expected failure")
    except ValueError:
        pass

    print(json.dumps({"ok": True}, ensure_ascii=False))


if __name__ == "__main__":
    main()
