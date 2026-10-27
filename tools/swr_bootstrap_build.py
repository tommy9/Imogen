"""Build the SWR bootstrap and stage the production DFS catalogue."""
import hashlib
import json
from pathlib import Path
import subprocess
from tools import sprite_assets


def build(assembler,root,verbose=False):
    output=root/'build/bootstrap';output.mkdir(exist_ok=True)
    names=('src/swr_bootstrap.asm','src/ssd_maker.asm','build/engine_exports.asm',
           'build/swr_boot_config.asm','src/swr_sprite_adapter.asm',
           'src/swr_renderer_core.asm','tools/swr_bootstrap_build.py',
           'build/swr_assets/bank_exports.asm','build/swr_assets/swr_bank.bin','build/g','build/imogen')
    inputs={name:hashlib.sha256((root/name).read_bytes()).hexdigest() for name in names}
    crc=(root/'build/swr_assets/swr_bank.bin').read_bytes()[0x34:0x38]
    (output/'bootstrap_crc.asm').write_text('; Exact generated image identity.\nEQUB '+','.join(f'&{b:02X}' for b in crc)+'\n')
    def assemble(source,stem):
        labels=output/(stem+'.labels')
        result=subprocess.run([assembler,'-i',str(source),'-labels',str(labels),'-dd'],cwd=root,capture_output=True,text=True)
        (root/'build/logs'/('bootstrap_'+stem+'.log')).write_text(result.stdout+result.stderr)
        if verbose:print(result.stdout+result.stderr)
        if result.returncode:raise sprite_assets.AssetError('Bootstrap assembly failed: '+result.stdout+result.stderr)
        return sprite_assets.load_labels(labels)
    labels=assemble(root/'src/swr_bootstrap.asm','bootstrap')
    maker=(root/'src/ssd_maker.asm').read_text()
    (output/'ssd_maker.asm').write_text(maker)
    report={'bootstrap_load':labels['.boot_start'],'bootstrap_end':labels['.boot_end'],
            'chunk_buffer':[0x3000,0x3400],'bank_file':'SWBANK','engine_file':'GAME',
            'logo_loader_changed':False,'renderer_switched':True,'inputs':inputs}
    if any(hashlib.sha256((root/name).read_bytes()).hexdigest()!=digest
           for name,digest in inputs.items()):
        raise sprite_assets.AssetError('A bootstrap input changed during bootstrap assembly')
    (output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    return output/'ssd_maker.asm'
