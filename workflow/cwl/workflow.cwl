#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  gendata_tool: File
  fitdata_tool: File
  events: int

outputs:
  plot:
    type: File
    outputSource:
      fitdata/result
  gendata.log:
    type: File
    outputSource:
      gendata/gendata.log
  fitdata.log:
    type: File
    outputSource:
      fitdata/fitdata.log

steps:
  gendata:
    run: gendata.cwl
    in:
      gendata_tool: gendata_tool
      events: events
    out: [data, gendata.log]
  fitdata:
    run: fitdata.cwl
    in:
      fitdata: fitdata_tool
      data: gendata/data
    out: [result, fitdata.log]
