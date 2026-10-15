#!/usr/bin/env python3
"""Deterministic source and install packages for GuildRecruit735."""
from pathlib import Path
from zipfile import ZipFile,ZipInfo,ZIP_DEFLATED
import hashlib, json, re
ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/"GuildRecruit735"
DIST=ROOT/"dist"
VERSION="1.0.4"
BUILD="GR735-20261015-04"
NAME=f"GuildRecruit735-{VERSION}-{BUILD}"
STAMP=(2026,10,15,0,0,0)

def h(data): return hashlib.sha256(data).hexdigest()
def buildzip(file,paths):
    with ZipFile(file,"w",ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(paths):
            arc=p.relative_to(ROOT).as_posix()
            zi=ZipInfo(arc,STAMP)
            zi.create_system=3
            zi.compress_type=ZIP_DEFLATED
            zi.external_attr=0o644 << 16
            z.writestr(zi,p.read_bytes(),compress_type=ZIP_DEFLATED,compresslevel=9)
        assert z.testzip() is None
    return {"file":file.name,"size":file.stat().st_size,"sha256":h(file.read_bytes())}

def main():
    DIST.mkdir(exist_ok=True)
    install=sorted(ADDON.glob("*.lua"))+[ADDON/"GuildRecruit735.toc",ADDON/"LICENSE"]
    assert len(install)==11
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
       "provenance":"GR735_20261015_04_FROM_GR735_20261015_03_4beaff1e_RELEASE_1_0_4_METADATA_ONLY",
       "baseline":"OWN_1_0_4_TEST_GR735-20261015-03",
       "parent_install":{"version":"1.0.4-TEST","build":"GR735-20261015-03",
         "sha256":"4beaff1e895082ccd5f7e0fdca14e928472733498803a16becac24bd3b6d6e22"},
       "parent_source_sha256":"c38c2a520d798c0314be7ac0eb66b7dee73e857c2018baab75c0eb4afb17eabc",
       "user_install":user,"source_archive":source_zip,
       "install_files":{p.relative_to(ROOT).as_posix():h(p.read_bytes()) for p in sorted(install)},
       "status":"STABLE_RELEASE / USER_ACCEPTED_UI_IN_PARENT / EXACT_STABLE_METADATA_ONLY",
       "game":"User accepted interface and filters on direct TEST parent; exact stable differs only in version/build metadata; full taint/HC/x100 regression not claimed",
       "prior_game_evidence":"0.1.4 GAME_TEST_004: narrow minimap/WHO/receiver screenshot; 0.1.5 GAME_TEST_005: English GUI and WHO 12/9 screenshot; no full 1.0.0 runtime coverage.",
       "native_lua_5_1":"Native Lua5.1 compile and RU/EN581 regression gate; GitHub Actions runs standalone luac5.1 and Lua5.1 on exact commit"
    }
    (DIST/(BUILD+"_MANIFEST.json")).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"install":user,"source":source_zip},indent=2))
if __name__=="__main__": main()
