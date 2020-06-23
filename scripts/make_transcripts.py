#!/usr/bin/env python3

from pathlib import Path
import os

for filename in Path("build").glob("*.cast"):
    os.system(f"asciinema cat {filename} | ansifilter > transcripts/{filename.stem}.txt")
