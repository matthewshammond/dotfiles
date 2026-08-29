#!/usr/bin/env python3
"""Count, list, and upgrade outdated Homebrew formulae, casks, and Mac App Store apps.

SketchyBar inherits SIGCHLD=IGN, which makes Homebrew's Ruby crash. Restore
the default handler before spawning brew.
"""

from __future__ import annotations

import os
import signal
import subprocess
import sys
from pathlib import Path

signal.signal(signal.SIGCHLD, signal.SIG_DFL)

HOMEBREW_PREFIXES = (
    os.environ.get("HOMEBREW_PREFIX", ""),
    "/opt/homebrew",
    "/usr/local",
)

os.environ.setdefault("HOMEBREW_NO_ANALYTICS", "1")


def _which(name: str) -> str | None:
    for prefix in HOMEBREW_PREFIXES:
        if not prefix:
            continue
        candidate = Path(prefix) / "bin" / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    from shutil import which

    return which(name)


BREW = _which("brew")
MAS = _which("mas")
SKETCHYBAR = _which("sketchybar")


def _run(
    argv: list[str],
    *,
    capture: bool = False,
    extra_env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    if extra_env:
        env.update(extra_env)
    return subprocess.run(
        argv,
        capture_output=capture,
        text=True,
        env=env,
    )


def _lines(argv: list[str], extra_env: dict[str, str] | None = None) -> list[str]:
    result = _run(argv, capture=True, extra_env=extra_env)
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def formulae() -> list[str]:
    if not BREW:
        return []
    return _lines(
        [BREW, "outdated", "--formula", "--quiet"],
        extra_env={"HOMEBREW_NO_AUTO_UPDATE": "1"},
    )


def casks() -> list[str]:
    if not BREW:
        return []
    return _lines(
        [BREW, "outdated", "--cask", "--quiet"],
        extra_env={"HOMEBREW_NO_AUTO_UPDATE": "1"},
    )


def mas_apps() -> list[tuple[str, str]]:
    if not MAS:
        return []
    apps: list[tuple[str, str]] = []
    for line in _lines([MAS, "outdated"]):
        parts = line.split(None, 1)
        if not parts:
            continue
        app_id = parts[0]
        rest = parts[1] if len(parts) > 1 else app_id
        name = rest.split(" (")[0].strip() or rest
        apps.append((app_id, name))
    return apps


def cmd_count() -> int:
    total = len(formulae()) + len(casks()) + len(mas_apps())
    print(total)
    return 0


def cmd_list() -> int:
    for name in formulae():
        print(f"formula\t{name}")
    for name in casks():
        print(f"cask\t{name}")
    for _app_id, name in mas_apps():
        print(f"mas\t{name}")
    return 0


def cmd_fetch() -> int:
    if not BREW:
        print("brew not found", file=sys.stderr)
        return 1
    return _run([BREW, "update"]).returncode


def _trigger_sketchybar() -> None:
    if not SKETCHYBAR:
        return
    _run([SKETCHYBAR, "--trigger", "brew_update"])


def cmd_upgrade() -> int:
    if not BREW:
        print("brew not found", file=sys.stderr)
        return 1

    steps: list[tuple[str, list[str]]] = [
        ("brew update", [BREW, "update"]),
        ("brew upgrade", [BREW, "upgrade"]),
    ]
    for title, argv in steps:
        print(f"==> {title}", flush=True)
        result = _run(argv)
        if result.returncode != 0:
            print(f"error: {title} failed ({result.returncode})", file=sys.stderr)
            _trigger_sketchybar()
            return result.returncode

    leftover_casks = casks()
    if leftover_casks:
        # Auto-updating casks show in `brew outdated` but need --greedy to install.
        title = "brew upgrade --cask --greedy " + " ".join(leftover_casks)
        print(f"==> {title}", flush=True)
        result = _run([BREW, "upgrade", "--cask", "--greedy", *leftover_casks])
        if result.returncode != 0:
            print(f"error: {title} failed ({result.returncode})", file=sys.stderr)
            _trigger_sketchybar()
            return result.returncode

    for title, argv in (
        ("brew cleanup -s", [BREW, "cleanup", "-s"]),
        ("brew autoremove", [BREW, "autoremove"]),
    ):
        print(f"==> {title}", flush=True)
        result = _run(argv)
        if result.returncode != 0:
            print(f"error: {title} failed ({result.returncode})", file=sys.stderr)
            _trigger_sketchybar()
            return result.returncode

    if MAS:
        print("==> mas outdated && mas upgrade", flush=True)
        _run([MAS, "outdated"])
        _run([MAS, "upgrade"])
    else:
        print("mas not found; skipping Mac App Store updates", file=sys.stderr)

    cache = _run([BREW, "--cache"], capture=True)
    cache_path = (cache.stdout or "").strip()
    if cache.returncode == 0 and cache_path:
        print(f'==> rm -rf "{cache_path}"', flush=True)
        _run(["rm", "-rf", cache_path])

    print("==> sketchybar --trigger brew_update", flush=True)
    _trigger_sketchybar()
    return 0


def usage() -> None:
    prog = Path(sys.argv[0]).name
    print(
        f"usage: {prog} <count|list|fetch|upgrade>\n"
        "  count    Print outdated formulae + casks + mas apps\n"
        "  list     Print outdated items as type<TAB>name\n"
        "  fetch    Run brew update\n"
        "  upgrade  Update, upgrade, clean, and refresh SketchyBar",
        file=sys.stderr,
    )


def main() -> int:
    if len(sys.argv) != 2 or sys.argv[1] in {"-h", "--help"}:
        usage()
        return 0 if len(sys.argv) == 2 and sys.argv[1] in {"-h", "--help"} else 2
    command = sys.argv[1]
    commands = {
        "count": cmd_count,
        "list": cmd_list,
        "fetch": cmd_fetch,
        "upgrade": cmd_upgrade,
    }
    handler = commands.get(command)
    if not handler:
        usage()
        return 2
    return handler()


if __name__ == "__main__":
    sys.exit(main())
