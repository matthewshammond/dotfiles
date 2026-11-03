#!/usr/bin/env python3
"""Show/hide a camera source in EVERY OBS scene that contains it.

status reports the live (program) scene's copy of the source, or the first
scene that has it if the live scene doesn't. toggle sets every scene's copy
to the opposite of that state, so all scenes stay in sync.

Usage: obs_camera.py "<source>" status|on|off|toggle   -> prints "on" or "off"
Exits non-zero if OBS is unreachable or no scene has the source.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import obs_scene as obs  # noqa: E402

ACTIONS = ("status", "on", "off", "toggle")


def main():
    if len(sys.argv) != 3 or sys.argv[2] not in ACTIONS:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    source, action = sys.argv[1], sys.argv[2]
    try:
        sock = obs.connect(*obs.load_settings())
        live = obs.request(sock, "GetCurrentProgramScene")["currentProgramSceneName"]
        found = []
        for sc in obs.request(sock, "GetSceneList")["scenes"]:
            name = sc["sceneName"]
            for it in obs.request(sock, "GetSceneItemList", {"sceneName": name})["sceneItems"]:
                found.append((it["sourceName"], name, it["sceneItemId"], it["sceneItemEnabled"]))
        copies = [f[1:] for f in found if f[0] == source]
        if not copies:
            copies = [f[1:] for f in found if f[0].lower() == source.lower()]
        if not copies:
            raise RuntimeError(f'no scene contains a source named "{source}"')
        enabled = next((c[2] for c in copies if c[0] == live), copies[0][2])
        if action != "status":
            enabled = {"on": True, "off": False, "toggle": not enabled}[action]
            for name, item_id, _ in copies:
                obs.request(
                    sock,
                    "SetSceneItemEnabled",
                    {"sceneName": name, "sceneItemId": item_id, "sceneItemEnabled": enabled},
                )
        sock.close()
    except (OSError, ConnectionError, RuntimeError, ValueError, KeyError) as e:
        print(f"obs_camera: {e}", file=sys.stderr)
        return 1
    print("on" if enabled else "off")
    return 0


if __name__ == "__main__":
    sys.exit(main())
