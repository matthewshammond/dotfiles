#!/usr/bin/env python3
"""Show/hide the "Webcam" source over obs-websocket.

status reports the live (program) scene's Webcam. toggle sets Webcam in EVERY
scene that has it to the opposite of the live scene's state.

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
            for sc in obs.request(sock, "GetSceneList")["scenes"]:
                name = sc["sceneName"]
                for it in obs.request(sock, "GetSceneItemList", {"sceneName": name})["sceneItems"]:
                    if it["sourceName"] == SOURCE:
                        obs.request(sock, "SetSceneItemEnabled", {"sceneName": name, "sceneItemId": it["sceneItemId"], "sceneItemEnabled": enabled})
        sock.close()
    except (OSError, ConnectionError, RuntimeError, ValueError, KeyError) as e:
        print(f"obs_webcam: {e}", file=sys.stderr)
        return 1
    print("on" if enabled else "off")
    return 0


if __name__ == "__main__":
    sys.exit(main())
