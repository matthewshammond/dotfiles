#!/usr/bin/env python3
"""Print unread inbox counts for enabled Apple Mail accounts.

Output lines are: <count><TAB><account name>
"""

from __future__ import annotations

import signal
import subprocess
import sys

signal.signal(signal.SIGCHLD, signal.SIG_DFL)

MAIL_SCRIPT = r"""
tell application "Mail"
  set output to ""
  repeat with a in every account whose enabled is true
    try
      set unreadCount to 0
      try
        set unreadCount to unread count of mailbox "INBOX" of a
      on error
        try
          set unreadCount to unread count of mailbox "Inbox" of a
        end try
      end try
      set output to output & unreadCount & tab & (name of a as text) & linefeed
    end try
  end repeat
  return output
end tell
"""


def main() -> int:
    result = subprocess.run(
        ["/usr/bin/osascript"],
        input=MAIL_SCRIPT,
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        sys.stdout.write(result.stdout or "")
    return 0


if __name__ == "__main__":
    sys.exit(main())
