rule all:
    input:
        "results/data.root",
        "results/plot.png"

rule gendata:
    input:
        macro="gendata.C"
    output:
        "results/data.root"
    params:
        events=config["events"]
    container:
        "docker://docker.io/reanahub/reana-env-root6:6.18.04"
    resources:
        kubernetes_memory_limit="256Mi"
    shell:
        "mkdir -p results && root -b -q '{input.macro}({params.events},\"{output}\")'"

rule fitdata:
    input:
        data="results/data.root",
        macro="fitdata.C"
    output:
        "results/plot.png"
    container:
        "docker://docker.io/reanahub/reana-env-root6:6.18.04"
    resources:
        kubernetes_memory_limit="256Mi"
    shell:
        "root -b -q '{input.macro}(\"{input.data}\",\"{output}\")'"
