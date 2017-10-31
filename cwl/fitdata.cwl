cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      reanahub/reana-demo-root6-roofit

inputs:
  data: File
  outfile:
    type: string
    default: plot.png

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      cd /code;
      root -b -q 'fitdata.C("$(inputs.data.path)","$(runtime.outdir)/$(inputs.outfile)")'

outputs:
  result:
    type: File
    outputBinding:
      glob: $(inputs.outfile)
