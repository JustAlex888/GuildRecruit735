#!/usr/bin/env python3
"""Deterministic source and install packages for GuildRecruit735."""
from pathlib import Path
from zipfile import ZipFile,ZipInfo,ZIP_DEFLATED
import hashlib, json, re
ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/"GuildRecruit735"
DIST=ROOT/"dist"
VERSION="1.0.7"
BUILD="GR735-20261019-02"
NAME=f"GuildRecruit735-{VERSION}-{BUILD}"
STAMP=(2026,10,19,0,0,0)

def h(data): return hashlib.sha256(data).hexdigest()
def buildzip(file,paths):
    with ZipFile(file,"w",ZIP_DEFLATED,compresslevel=9) as z:
        for p in sorted(paths,key=lambda p:p.relative_to(ROOT).as_posix()):
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
    assert len(install)==13
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
       "provenance":"GR735_20261019_02_FROM_106_039850dc_MODULE_LOAD_HOTFIX",
       "baseline":"OWN_1_0_6_GR735-20261019-01",
       "parent_install":{"version":"1.0.6","build":"GR735-20261019-01",
         "sha256":"039850dc1d81ab87f413f27bf78b88b53bd9155ef96e681be47eb40e2702174c"},
       "parent_source_sha256":"d189c2ba7e9cc530cab6601f0fade1518d47fce041c47441ce3292df2a4e9ecd",
       "user_install":user,"source_archive":source_zip,
       "install_files":{p.relative_to(ROOT).as_posix():h(p.read_bytes()) for p in sorted(install)},
       "status":"PRERELEASE / STATIC_VERIFIED / READY_FOR_GAME_TEST",
       "game":"Prerelease for in-game testing. Real-client validation of the new logic is not yet confirmed. Historical missing-player attribution remains unverified. Published install must match exact Drive bytes.",
       "prior_game_evidence":"0.1.4 GAME_TEST_004: narrow minimap/WHO/receiver screenshot; 0.1.5 GAME_TEST_005: English GUI and WHO 12/9 screenshot; no full 1.0.0 runtime coverage.",
       "native_lua_5_1":"Native Lua5.1 compile and RU/EN selection regression gate. GitHub publication workflow verifies standalone Lua5.1 and exact installSHA; live CI result recorded separately."
    }
    (DIST/(BUILD+"_MANIFEST.json")).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"install":user,"source":source_zip},indent=2))
if __name__=="__main__": main()
