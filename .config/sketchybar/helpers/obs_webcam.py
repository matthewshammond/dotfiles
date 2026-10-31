#!/usr/bin/env python3
"""Show/hide the "Webcam" source in OBS's current program scene over obs-websocket.

Usage: obs_webcam.py status|toggle   -> prints "on" or "off"
Exits non-zero if OBS is unreachable or the scene has no Webcam source.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import obs_scene as obs  # noqa: E402

SOURCE = "Webcam"


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("status", "toggle"):
        print(__doc__.strip(), file=sys.stderr)
        return 2
    try:
        sock = obs.connect(*obs.load_settings())
        scene = obs.request(sock, "GetCurrentProgramScene")["currentProgramSceneName"]
        item = obs.request(sock, "GetSceneItemId", {"sceneName": scene, "sourceName": SOURCE})["sceneItemId"]
        ref = {"sceneName": scene, "sceneItemId": item}
        enabled = obs.request(sock, "GetSceneItemEnabled", ref)["sceneItemEnabled"]
        if sys.argv[1] == "toggle":
            enabled = not enabled
            obs.request(sock, "SetSceneItemEnabled", dict(ref, sceneItemEnabled=enabled))
        sock.close()
    except (OSError, ConnectionError, RuntimeError, ValueError, KeyError) as e:
        print(f"obs_webcam: {e}", file=sys.stderr)
        return 1
    print("on" if enabled else "off")
    return 0


if __name__ == "__main__":
    sys.exit(main())
