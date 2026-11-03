#!/usr/bin/env python3
"""Show/hide one source in one OBS scene over obs-websocket.

Usage: obs_source.py "<scene>" "<source>" status|on|off|toggle  -> prints "on" or "off"
       obs_source.py "<scene>" --list                            -> source names in the scene

Exits non-zero if OBS is unreachable or the source isn't in the scene.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import obs_scene as obs  # noqa: E402

ACTIONS = ("status", "on", "off", "toggle")


def main():
    args = sys.argv[1:]
    listing = len(args) == 2 and args[1] == "--list"
    if not listing and (len(args) != 3 or args[2] not in ACTIONS):
        print(__doc__.strip(), file=sys.stderr)
        return 2
    scene = args[0]
    try:
        sock = obs.connect(*obs.load_settings())
        items = obs.request(sock, "GetSceneItemList", {"sceneName": scene})["sceneItems"]
        if listing:
            for it in reversed(items):
                print(it["sourceName"])
            sock.close()
            return 0
        source, action = args[1], args[2]
        match = [it for it in items if it["sourceName"] == source]
        if not match:
            names = ", ".join(it["sourceName"] for it in items)
            raise RuntimeError(f'no source "{source}" in scene "{scene}" (has: {names})')
        item = match[0]
        enabled = item["sceneItemEnabled"]
        if action != "status":
            enabled = {"on": True, "off": False, "toggle": not enabled}[action]
            obs.request(
                sock,
                "SetSceneItemEnabled",
                {"sceneName": scene, "sceneItemId": item["sceneItemId"], "sceneItemEnabled": enabled},
            )
        sock.close()
    except (OSError, ConnectionError, RuntimeError, ValueError, KeyError) as e:
        print(f"obs_source: {e}", file=sys.stderr)
        return 1
    print("on" if enabled else "off")
    return 0


if __name__ == "__main__":
    sys.exit(main())
