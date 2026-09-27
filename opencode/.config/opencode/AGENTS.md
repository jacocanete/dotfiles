## OpenCode agents
- Build implements and verifies approved changes. Plan investigates and proposes, read-only.
- Both work directly; subagent delegation is disabled in this setup, so investigate yourself.
- Put repeatable workflows in skills rather than new agents or permission profiles.
- Run OCR through `/ocr-review` after writing is finished; Build owns fixes.
- OpenCode Web runs as a systemd user service at `http://10.121.16.20:4096`; the phone reaches only this port.
