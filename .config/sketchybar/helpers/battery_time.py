#!/usr/bin/env python3
"""Print battery time remaining as H:MMh.

Newer macOS often prints "(no estimate)" from `pmset` even when IOKit
still has TimeRemaining. Fall back to that, then to capacity / current.
"""

from __future__ import annotations

import re
import subprocess
import sys

UNKNOWN_MINUTES = 65535


def _run(argv: list[str]) -> str:
    return subprocess.check_output(argv, text=True)


def _i64(n: int) -> int:
    return n - (1 << 64) if n >= (1 << 63) else n


def _grab_int(text: str, key: str) -> int | None:
    match = re.search(rf'"{re.escape(key)}"\s*=\s*(-?\d+)', text)
    return int(match.group(1)) if match else None


def _yes(text: str, key: str) -> bool:
    match = re.search(rf'"{re.escape(key)}"\s*=\s*(\w+)', text)
    return bool(match and match.group(1) == "Yes")


def _fmt(minutes: int) -> str:
    minutes = max(0, min(minutes, 99 * 60 + 59))
    hours, mins = divmod(minutes, 60)
    return f"{hours}:{mins:02d}h"


def from_pmset(text: str) -> str | None:
    match = re.search(r"(\d+:\d+)\s+remaining", text)
    return f"{match.group(1)}h" if match else None


def from_ioreg(text: str) -> str | None:
    remaining = _grab_int(text, "TimeRemaining")
    if remaining is not None and 0 < remaining < UNKNOWN_MINUTES:
        return _fmt(remaining)

    charging = _yes(text, "IsCharging")
    external = _yes(text, "ExternalConnected")
    charged = _yes(text, "FullyCharged")
    if charged or (external and not charging and remaining == 0):
        return "Charged"

    amps = _grab_int(text, "InstantAmperage")
    if amps is None:
        amps = _grab_int(text, "Amperage")
    if amps is None:
        return "On AC" if external else None
    amps = _i64(amps)

    current = _grab_int(text, "AppleRawCurrentCapacity")
    maximum = _grab_int(text, "AppleRawMaxCapacity")
    if amps < -10 and current:
        return _fmt(int(current / abs(amps) * 60))
    if amps > 10 and current is not None and maximum and maximum > current:
        return _fmt(int((maximum - current) / amps * 60))
    if external:
        return "Charged" if charged else "On AC"
    return None


def main() -> int:
    try:
        label = from_pmset(_run(["/usr/bin/pmset", "-g", "batt"]))
        if not label:
            label = from_ioreg(_run(["/usr/sbin/ioreg", "-n", "AppleSmartBattery", "-r"]))
        print(label or "No estimate")
    except (OSError, subprocess.CalledProcessError):
        print("No estimate")
    return 0


if __name__ == "__main__":
    sys.exit(main())
