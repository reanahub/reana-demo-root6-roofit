==================================
 REANA example - ROOT6 and RooFit
==================================

.. image:: https://img.shields.io/travis/reanahub/reana-demo-root6-roofit.svg
   :target: https://travis-ci.org/reanahub/reana-demo-root6-roofit

.. image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

.. image:: https://img.shields.io/github/license/reanahub/reana-demo-root6-roofit.svg
   :target: https://github.com/reanahub/reana-demo-root6-roofit/blob/master/LICENSE

About
=====

This `REANA <http://www.reana.io/>`_ reproducible analysis example emulates a
typical particle physics analysis where the signal and background data is
processed and fitted against a model. The example will use the `RooFit
<https://root.cern.ch/roofit>`_ package of the `ROOT <https://root.cern.ch/>`_
framework.

Analysis structure
==================

Making a research data analysis reproducible basically means to provide
"runnable recipes" addressing (1) where is the input data, (2) what software was
used to analyse the data, (3) which computing environments were used to run the
software and (4) which computational workflow steps were taken to run the
analysis. This will permit to instantiate the analysis on the computational
cloud and run the analysis to obtain (5) output results.

1. Input data
-------------

In this example, the signal and background data will be generated; see below.
Therefore there is no explicit input file to be taken care of.

2. Analysis code
----------------

The analysis will consist of two stages. In the first stage, signal and
background are generated. In the second stage, a fit will be made for the signal
and background.

For the first generation stage, `gendata.C <gendata.C>`_ is a ROOT macro that
generates signal and background data.

For the second fitting stage, `fitdata.C <fitdata.C>`_ is a ROOT macro that
makes a fit for the signal and the background data.

The code was taken from the RooFit tutorial `rf502_wspacewrite.C
<https://root.cern.ch/root/html/tutorials/roofit/rf502_wspacewrite.C.html>`_ and
was slightly modified.

3. Compute environment
----------------------

In order to be able to rerun the analysis even several years in the future, we
need to "encapsulate the current compute environment", for example to freeze the
ROOT version our analysis is using. We shall achieve this by preparing a `Docker
<https://www.docker.com/>`_ container image for our analysis steps.

This analysis example is runs within the `ROOT6 <https://root.cern.ch/>`_
analysis framework. The computing environment can be therefore easily
encapsulated by using the upstream `reana-env-root6
<https://github.com/reanahub/reana-env-root6>`_ base image. (See there how it
was created.)

We can actually use this container image "as is", because our two macros
``gendata.C`` and ``fitdata.C`` can be "uploaded" or "mounted" into the runtime
container. We therefore don't need to create any specially customised
environment.

4. Analysis workflow
--------------------

The analysis workflow is simple and consists of two above-mentioned stages:

.. code-block:: console

              START
               |
               |
               V
   +-------------------------+
   | (1) generate data       |
   |                         |
   |    $ root gendata.C ... |
   +-------------------------+
               |
               | data.root
               V
   +-------------------------+
   | (2) fit data            |
   |                         |
   |    $ root fitdata.C ... |
   +-------------------------+
               |
               | plot.png
               V
              STOP

For example:

.. code-block:: console

    $ root -b -q 'gendata.C(20000,"data.root")'
    $ root -b -q 'fitdata.C("data.root","plot.png")'
    $ ls -l plot.png

Note that you can also use `CWL <http://www.commonwl.org/v1.0/>`_ or `Yadage
<https://github.com/diana-hep/yadage>`_ workflow specifications:

- `workflow definition using CWL <workflow/cwl/workflow.cwl>`_
- `workflow definition using Yadage <workflow/yadage/workflow.yaml>`_

5. Output results
-----------------

The example produces a plot where the signal and background data is fitted
against the model:

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-root6-roofit/master/docs/plot.png
   :alt: plot.png
   :align: center

Running the example on REANA cloud
==================================

We start by creating a `reana.yaml <reana.yaml>`_ file describing the above
analysis structure with its inputs, code, runtime environment, computational
workflow steps and expected outputs:

.. code-block:: yaml

    version: 0.3.0
    inputs:
      files:
        - code/gendata.C
        - code/fitdata.C
    parameters:
      events: 20000
      data: results/data.root
      plot: results/plot.png
    workflow:
      type: serial
      specification:
        steps:
          - environment: 'reanahub/reana-env-root6'
            commands:
            - mkdir -p results
            - root -b -q 'code/gendata.C(${events},"${data}")' | tee gendata.log
            - root -b -q 'code/fitdata.C("${data}","${plot}")' | tee fitdata.log
    outputs:
      files:
        - results/plot.png

In this example we are using a simple Serial workflow engine to represent our
sequential computational workflow steps. Note that we can also use the CWL
workflow specification (see `reana-cwl.yaml <reana-cwl.yaml>`_) or the Yadage
workflow specification (see `reana-yadage.yaml <reana-yadage.yaml>`_).

We can now install the REANA command-line client, run the analysis and download the resulting plots:

.. code-block:: console

    $ # create new virtual environment
    $ virtualenv ~/.virtualenvs/myreana
    $ source ~/.virtualenvs/myreana/bin/activate
    $ # install REANA client
    $ pip install reana-client
    $ # connect to some REANA cloud instance
    $ export REANA_SERVER_URL=https://reana.cern.ch/
    $ export REANA_ACCESS_TOKEN=XXXXXXX
    $ # create new workflow
    $ reana-client create -n my-analysis
    $ export REANA_WORKON=my-analysis
    $ # upload input code and data to the workspace
    $ reana-client upload ./code
    $ # start computational workflow
    $ reana-client start
    $ # ... should be finished in about a minute
    $ reana-client status
    $ # list workspace files
    $ reana-client list
    $ # download output results
    $ reana-client download results/plot.png

Please see the `REANA-Client <https://reana-client.readthedocs.io/>`_
documentation for more detailed explanation of typical ``reana-client`` usage
scenarios.

Contributors
============

The list of contributors in alphabetical order:

- `Ana Trisovic <https://orcid.org/0000-0003-1991-0533>`_
- `Anton Khodak <https://orcid.org/0000-0003-3263-4553>`_
- `Daniel Prelipcean <https://orcid.org/0000-0002-4855-194X>`_
- `Diego Rodriguez <https://orcid.org/0000-0003-0649-2002>`_
- `Dinos Kousidis <https://orcid.org/0000-0002-4914-4289>`_
- `Lukas Heinrich <https://orcid.org/0000-0002-4048-7584>`_
- `Rokas Maciulaitis <https://orcid.org/0000-0003-1064-6967>`_
- `Tibor Simko <https://orcid.org/0000-0001-7202-5803>`_
