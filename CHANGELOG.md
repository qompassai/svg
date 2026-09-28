# Changelog — qompassai/svg

## 2026-09-28 — License normalization to Apache 2.0

**Decision (per Matt's directive):** the project's license is now Apache
License 2.0 ONLY.

- **Removed** `LICENSE-AGPL` (GNU Affero General Public License v3) and
  `LICENSE-QCDA` (Qompass Commercial Distribution Agreement 1.0). The
  previous dual-license model (AGPL-3.0 for open use + Q-CDA commercial
  option) is retired for this repo. Rationale per Matt: a single
  permissive license (Apache 2.0) for all Qompass AI language projects.
- **Added** `LICENSE` — the complete, unmodified Apache License 2.0 text
  (https://www.apache.org/licenses/LICENSE-2.0.txt), appendix attributing
  `Copyright 2025 Qompass AI` (year kept from the repo's existing
  copyright headers).
- **README.md**: replaced the AGPL v3 + Q-CDA badges with an Apache 2.0
  badge; removed the entire "Dual-License Notice" section (AGPL
  rationale, commercial-option rationale, cybersecurity references) and
  replaced it with a concise `## License` section pointing at `./LICENSE`.
- **`copyright`** (Debian copyright-format file declaring the project's
  own license): `License:` stanza changed from `AGPL-3.0` to `Apache-2.0`
  and the embedded full AGPL-3.0 text replaced with the full Apache
  License 2.0 text. This file describes the project's own licensing, not
  third-party content.
- **Metadata**: `.zenodo.json` and `CITATION.cff` license fields updated
  from `Q-CDA-1.0` to the SPDX identifier `Apache-2.0`; the license value
  in the `create_zenodo.py` generator script updated to `"Apache-2.0"` so
  regenerating the metadata cannot reintroduce the retired licenses.

**Exceptions:** none — no vendored third-party directories or submodules
with their own licenses were found in this repo.

**Validation:** `LICENSE` diffed against the canonical apache.org text
(only the appendix copyright line differs, as intended); `.zenodo.json`
parses as JSON; README renders (no broken badge/link references remain
to the deleted license files — verified zero matches for
AGPL/Q-CDA/dual-license strings outside this changelog); the `copyright`
file's license stanza and embedded text verified as Apache 2.0.
