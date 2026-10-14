#!/usr/bin/env python3
"""Deterministic source and install packages for GuildRecruit735."""
from pathlib import Path
from zipfile import ZipFile,ZipInfo,ZIP_DEFLATED
import hashlib, json, re
ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/"GuildRecruit735"
DIST=ROOT/"dist"
VERSION="1.0.0"
BUILD="GR735-20261014-03"
NAME=f"GuildRecruit735-{VERSION}-{BUILD}"
STAMP=(2026,10,14,0,0,0)

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
       "provenance":"GR735_20261014_03_FROM_GR735_20261014_02_fe2c7c4a_RELEASE_1_0_0_METADATA_ONLY",
       "baseline":"INDEPENDENT_ORIGINAL_PARENT_GR735-20261014-02",
       "parent_install":{"version":"0.1.5-TEST","build":"GR735-20261014-02",
         "sha256":"fe2c7c4a420a9d38c109544bd48856c438037922db30cff5e00aaf12cb57aef3"},
       "parent_source_sha256":"c76d77b8bd1827ed106a2d21083219ab365c8cc260de915425b33b9f587a8356",
       "user_install":user,"source_archive":source_zip,
       "install_files":{p.relative_to(ROOT).as_posix():h(p.read_bytes()) for p in sorted(install)},
       "status":"STATIC_VERIFIED_WITH_LIMITATIONS / RELEASE_CANDIDATE_READY",
       "game":"PARTIAL_OBSERVATION_ONLY (inherited evidence only; 1.0.0 NOT_OBSERVED)",
       "prior_game_evidence":"0.1.4 GAME_TEST_004: narrow minimap/WHO/receiver screenshot; 0.1.5 GAME_TEST_005: English GUI and WHO 12/9 screenshot; no full 1.0.0 runtime coverage.",
       "native_lua_5_1":"BLOCKED_DEPENDENCY (not available locally)"
    }
    (DIST/(BUILD+"_MANIFEST.json")).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"install":user,"source":source_zip},indent=2))
if __name__=="__main__": main()
