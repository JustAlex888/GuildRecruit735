"""Native Lua5.1 syntax/fixture gate; no WoW verification claim."""
from pathlib import Path
import sys,io,contextlib,os,re,subprocess,shutil
def vm():
    # Normal installation: pip install lupa. Local task may point to a preinstalled runtime.
    if os.environ.get('GR735_LUPA_PATH'):
        sys.path.insert(0,os.environ['GR735_LUPA_PATH'])
    from lupa.lua51 import LuaRuntime
    lua=LuaRuntime(unpack_returned_tuples=True)
    assert lua.eval('_VERSION')=='Lua 5.1'
    lua.execute('assert(os.setlocale("C"))')
    return lua
def compile_all(addon):
    compiler=shutil.which('luac5.1')
    if compiler:
        for p in sorted(Path(addon).glob('*.lua')):
            subprocess.run([compiler,'-p',str(p)],check=True)
        return
    lua=vm()
    for p in sorted(Path(addon).glob('*.lua')):
        lua.execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
def execute_fixture(root,loc,dock):
    root=Path(root).resolve()
    args={1:(root/'GuildRecruit735').as_posix(),2:loc}
    if dock: args[3]=(root/'tests/test_docking.lua').as_posix()
    runtime=shutil.which('lua5.1')
    if runtime:
        p=subprocess.run([runtime,str(root/'tests/test_runtime.lua')]+list(args.values()),capture_output=True,text=True,encoding='utf-8')
        assert p.returncode==0,p.stderr
        output=p.stdout
    else:
        lua=vm();output=[]
        lua.globals().print=lambda *s:output.append(' '.join(str(x) for x in s))
        lua.globals().arg=lua.table_from(args)
        lua.execute((root/'tests/test_runtime.lua').read_text(encoding='utf-8'))
        output='\n'.join(output)
    print(output)
    return int(re.search(r'GR735 fixture PASS (\d+) assertions',output)[1])
