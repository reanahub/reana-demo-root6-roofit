cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      /cvmfs/unpacked.cern.ch/registry.hub.docker.com/rootproject/root:6.28.04-fedora37
  InitialWorkDirRequirement:
    listing:
      - $(inputs.gendata_tool)

inputs:
  gendata_tool: File
  events: int
  outfilename:
    type: string
    default: data.root

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      root -b -q '$(inputs.gendata_tool.basename)($(inputs.events),"$(runtime.outdir)/$(inputs.outfilename)")'

outputs:
  data:
    type: File
    outputBinding:
      glob: $(inputs.outfilename)
