cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      reanahub/reana-demo-root6-roofit

inputs:
  events: int
  outfilename:
    type: string
    default: data.root

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      cd /code;
      root -b -q 'gendata.C($(inputs.events),"$(runtime.outdir)/$(inputs.outfilename)")'

outputs:
  data:
    type: File
    outputBinding:
      glob: $(inputs.outfilename)
