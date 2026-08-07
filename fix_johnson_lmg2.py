# -*- coding: utf-8 -*-
"""Fix johnson lmg2 / johnson lmg2 prone:
The stop controls were placed in frames BEYOND the animation `end` attribute,
so they never execute during the loop=1 playback. Move them to the last frame
that is <= end, matching the working war2 structure
(weak_hand=0, stop=1, strong_hand=1)."""
import re

PATH = r"c:\Users\sfg1.DESKTOP-N02A6BA\Desktop\mymod\models\soldier_animations.xml"

with open(PATH, encoding="utf-8") as f:
    text = f.read()


def get_block(t, comment):
    pat = re.compile(
        r'(<animation\s+[^>]*comment="' + re.escape(comment) + r'">.*?</animation>)',
        re.DOTALL,
    )
    m = pat.search(t)
    assert m, "not found: " + comment
    return m.group(0)


def apply_on_block(t, comment, old, new):
    blk = get_block(t, comment)
    n = blk.count(old)
    assert n == 1, f"expected 1 occurrence in '{comment}', got {n}:\n{old[:80]}..."
    t = t.replace(blk, blk.replace(old, new))
    return t


# ---- standing: reloading, johnson lmg2 ----
# A) remove misplaced stop controls from frame 1.250 (beyond end=1.150)
text = apply_on_block(
    text,
    "reloading, johnson lmg2",
    """            <position x="5.154892" y="0.392032" z="4.682786" />
            <control key="weak_hand" value="0" />
            <control key="stop" value="1" />
        </frame>
    </animation>""",
    """            <position x="5.154892" y="0.392032" z="4.682786" />
        </frame>
    </animation>""",
)

# B) add weak_hand=0, stop=1 BEFORE strong_hand=1 in frame 1.150 (last <= end)
text = apply_on_block(
    text,
    "reloading, johnson lmg2",
    """            <position x="5.154892" y="0.392032" z="4.682786" />
            <control key="strong_hand" value="1" />
        </frame>
        <frame time="1.250000">""",
    """            <position x="5.154892" y="0.392032" z="4.682786" />
            <control key="weak_hand" value="0" />
            <control key="stop" value="1" />
            <control key="strong_hand" value="1" />
        </frame>
        <frame time="1.250000">""",
)

# ---- prone: reloading, johnson lmg2, prone ----
# C) add weak_hand=0, stop=1, strong_hand=1 to frame 0.875 (last <= end)
text = apply_on_block(
    text,
    "reloading, johnson lmg2, prone",
    """            <position x="1.242175" y="3.861485" z="-42.011276" />
        </frame>
        <frame time="0.925000">""",
    """            <position x="1.242175" y="3.861485" z="-42.011276" />
            <control key="weak_hand" value="0" />
            <control key="stop" value="1" />
            <control key="strong_hand" value="1" />
        </frame>
        <frame time="0.925000">""",
)

# D) remove misplaced stop controls from frame 0.975 (beyond end=0.875)
text = apply_on_block(
    text,
    "reloading, johnson lmg2, prone",
    """            <position x="1.293325" y="3.767021" z="-42.021435" />
            <control key="strong_hand" value="1" />
            <control key="weak_hand" value="0" />
            <control key="stop" value="1" />
        </frame>
    </animation>""",
    """            <position x="1.293325" y="3.767021" z="-42.021435" />
            <control key="strong_hand" value="1" />
        </frame>
    </animation>""",
)

with open(PATH, "w", encoding="utf-8", newline="") as f:
    f.write(text)

print("Fixes applied successfully.")


# ---- verification ----
def summarize(comment):
    t = open(PATH, encoding="utf-8").read()
    b = get_block(t, comment)
    m = re.match(r'<animation\s+([^>]*)>', b)
    print("\n### " + comment)
    print("  tag: " + m.group(1))
    frames = re.findall(r'<frame\s+time="([\d.]+)">(.*?)</frame>', b, re.DOTALL)
    for tm, inner in frames:
        ctrls = re.findall(r'<control\s+key="([^"]+)"\s+value="([^"]+)"', inner)
        if ctrls:
            print(f"  t={tm:<8} " + ", ".join(f"{k}={v}" for k, v in ctrls))


summarize("reloading, johnson lmg2")
summarize("reloading, johnson lmg2, prone")
