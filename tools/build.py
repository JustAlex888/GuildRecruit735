#!/usr/bin/env python3
"""Deterministic source and install packages for GuildRecruit735."""
from pathlib import Path
from zipfile import ZipFile,ZipInfo,ZIP_DEFLATED
import hashlib, json, re
ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/"GuildRecruit735"
DIST=ROOT/"dist"
VERSION="1.0.2"
BUILD="GR735-20261015-01"
NAME=f"GuildRecruit735-{VERSION}-{BUILD}"
STAMP=(2026,10,15,0,0,0)

def h(data): return hashlib.sha256(data).hexdigest()
def buildzip(file,paths):
    with ZipFile(file,"w",ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(paths):
            arc=p.relative_to(ROOT).as_posix()
            zi=ZipInfo(arc,STAMP)
            zi.compress_type=ZIP_DEFLATED
            zi.external_attr=0o644 << 16
            z.writestr(zi,p.read_bytes(),compress_type=ZIP_DEFLATED,compresslevel=9)
        assert z.testzip() is None
    return {"file":file.name,"size":file.stat().st_size,"sha256":h(file.read_bytes())}

def main():
    DIST.mkdir(exist_ok=True)
    install=sorted(ADDON.glob("*.lua"))+[ADDON/"GuildRecruit735.toc",ADDON/"LICENSE"]
    assert len(install)==10
    assert b"## Interface: 70300" in (ADDON/"GuildRecruit735.toc").read_bytes()
    assert b"## Version: "+VERSION.encode() in (ADDON/"GuildRecruit735.toc").read_bytes()
    source=install+sorted((ROOT/"docs").glob("*.md"))+sorted((ROOT/"tests").glob("*.lua"))+sorted((ROOT/"tools").glob("*.py"))
    source+=sorted((ROOT/".github/workflows").glob("*.yml"))
    source+=sorted((ROOT/"docs/screenshots").glob("*.png"))
    source+=[ROOT/"README.md",ROOT/"README.en.md",ROOT/"CHANGELOG.md",ROOT/"LICENSE",ROOT/".gitignore"]
    source=list(dict.fromkeys(source))
    user=buildzip(DIST/(NAME+".zip"),install)
    source_zip=buildzip(DIST/(NAME+"-SOURCE.zip"),source)
    manifest={
       "product":"GuildRecruit735","version":VERSION,"build":BUILD,
       "provenance":"GR735_20261015_01_FROM_GR735_20261014_05_3e401fe4_RELEASE_1_0_2_METADATA_ONLY",
       "baseline":"OWN_1_0_2_TEST_GR735-20261014-05",
       "parent_install":{"version":"1.0.2-TEST","build":"GR735-20261014-05",
         "sha256":"3e401fe4be322b626c27ed8df2cfb17807f51a81d818cd16d1b6e9bc87a35620"},
       "parent_source_sha256":"07e8fa0b4757854de674fd39dd097a3c23362209f774ca47e19ce4d270bb958c",
       "user_install":user,"source_archive":source_zip,
       "install_files":{p.relative_to(ROOT).as_posix():h(p.read_bytes()) for p in sorted(install)},
       "status":"STATIC_VERIFIED_WITH_LIMITATIONS / PUBLIC_RELEASE_CANDIDATE / TAINT_RETEST_PENDING",
       "game":"1.0.2-TEST level range user-reported working; EXACT 1.0.2 stable GAME_NOT_OBSERVED; other paths unverified",
       "prior_game_evidence":"0.1.4 GAME_TEST_004: narrow minimap/WHO/receiver screenshot; 0.1.5 GAME_TEST_005: English GUI and WHO 12/9 screenshot; no full 1.0.0 runtime coverage.",
       "native_lua_5_1":"GitHub Actions native Lua 5.1 gate planned for exact 1.0.2; local Lua5.1 unavailable"
    }
    (DIST/(BUILD+"_MANIFEST.json")).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"install":user,"source":source_zip},indent=2))
if __name__=="__main__": main()
