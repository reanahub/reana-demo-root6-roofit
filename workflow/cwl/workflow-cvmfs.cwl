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

steps:
  gendata:
    hints:
      reana:
        kubernetes_memory_limit: '256Mi'
    run: gendata-cvmfs.cwl
    in:
      gendata_tool: gendata_tool
      events: events
    out: [data]
  fitdata:
    hints:
      reana:
        kubernetes_memory_limit: '256Mi'
    run: fitdata-cvmfs.cwl
    in:
      fitdata: fitdata_tool
      data: gendata/data
    out: [result]

$namespaces:
  reana: https://www.reana.io
