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

Local testing
=============

*Optional*

If you would like to test the analysis locally (i.e. outside of the REANA
platform), you can proceed as follows.

Using pure Docker:

.. code-block:: console

    $ mkdir -p inputs
    $ rm -rf outputs && mkdir outputs
    $ docker run -i -t  --rm \
                  -v `pwd`/code:/code \
                  -v `pwd`/inputs:/inputs \
                  -v `pwd`/outputs:/outputs \
                  reanahub/reana-env-root6 \
              root -b -q '/code/gendata.C(20000,"/outputs/data.root")'
    $ docker run -i -t  --rm \
                  -v `pwd`/code:/code \
                  -v `pwd`/inputs:/inputs \
                  -v `pwd`/outputs:/outputs \
                  reanahub/reana-env-root6 \
              root -b -q '/code/fitdata.C("/outputs/data.root","/outputs/plot.png")'
    $ ls -l outputs/plot.png

In case you are using CWL workflow specification:

.. code-block:: console

    $ mkdir cwl-local-run
    $ cd cwl-local-run
    $ cp ../code/* ../workflow/cwl/input.yml .
    $ cwltool --quiet --outdir="../outputs" ../workflow/cwl/workflow.cwl input.yml
    $ ls -l outputs/plot.png

In case you are using Yadage workflow specification:

.. code-block:: console

    $ mkdir -p yadage-local-run/yadage-inputs
    $ cd yadage-local-run
    $ cp -a ../code ../inputs yadage-inputs
    $ yadage-run . ../workflow/yadage/workflow.yaml \
          -p events=20000 \
          -p gendata=code/gendata.C \
          -p fitdata=code/fitdata.C \
          -d initdir=`pwd`/yadage-inputs
    $ ls -l outputs/plot.png

Running the example on REANA cloud
==================================

First we need to create a `reana.yaml <reana.yaml>`_ file describing the
structure of our analysis with its inputs, the code, the runtime environment,
the workflow and the expected outputs:

.. code-block:: yaml

    version: 0.3.0
    code:
      files:
      - code/gendata.C
      - code/fitdata.C
    inputs:
      parameters:
        events: 20000
    outputs:
      files:
      - outputs/plot.png
    environments:
      - type: docker
        image: reanahub/reana-env-root6
    workflow:
      type: serial
      specification:
        steps:
          - environment: 'reanahub/reana-env-root6'
            commands:
            - root -b -q 'code/gendata.C(20000,"data.root")'
            - root -b -q 'code/fitdata.C("data.root","plot.png")'

In case you are using CWL or Yadage workflow specifications:

- `reana.yaml using CWL <reana-cwl.yaml>`_
- `reana.yaml using Yadage <reana-yadage.yaml>`_

We proceed by installing the REANA command-line client:

.. code-block:: console

    $ mkvirtualenv reana-client
    $ pip install reana-client

We should now connect the client to the remote REANA cloud where the analysis
will run. We do this by setting the ``REANA_SERVER_URL`` environment variable
and ``REANA_ACCESS_TOKEN`` with a valid access token:

.. code-block:: console

    $ export REANA_SERVER_URL=https://reana.cern.ch/
    $ export REANA_ACCESS_TOKEN=<ACCESS_TOKEN>

Note that if you `run REANA cluster locally
<http://reana-cluster.readthedocs.io/en/latest/gettingstarted.html#deploy-reana-cluster-locally>`_
on your laptop, you would do:

.. code-block:: console

    $ eval $(reana-cluster env --all)

Let us test the client-to-server connection:

.. code-block:: console

    $ reana-client ping
    Connected to https://reana.cern.ch - Server is running.

We proceed to create a new workflow instance:

.. code-block:: console

    $ reana-client create
    workflow.1
    $ export REANA_WORKON=workflow.1

We can now seed the analysis workspace with input files:

.. code-block:: console

    $ reana-client upload ./code
    File code/gendata.C was successfully uploaded.
    File code/fitdata.C was successfully uploaded.

    $ reana-client files list
    NAME             SIZE     LAST-MODIFIED
    code/gendata.C   1937     2018-08-06 14:38:08.580034+00:00
    code/fitdata.C   1648     2018-08-06 14:38:08.580034+00:00

We can now start the workflow execution:

.. code-block:: console

    $ reana-client start
    workflow.1 has been started.

After several minutes the workflow should be successfully finished. Let us query
its status:

.. code-block:: console

    $ reana-client status
    NAME       RUN_NUMBER   CREATED               STATUS     PROGRESS
    workflow   1            2018-08-06T14:39:57   finished   2/2

We can list the output files:

.. code-block:: console

    $ reana-client list
    NAME        SIZE     LAST-MODIFIED
    plot.png         16273    2018-08-06 14:40:13.842977+00:00
    fitdata.log      5399     2018-08-06 14:40:13.711978+00:00
    gendata.log      2137     2018-08-06 14:40:08.582034+00:00
    data.root        153040   2018-08-06 14:40:08.582034+00:00
    code/gendata.C   1937     2018-08-06 14:40:08.580034+00:00
    code/fitdata.C   1648     2018-08-06 14:40:08.580034+00:00

We finish by downloading the generated plot:

.. code-block:: console

    $ reana-client download plot.png
    File plot.png downloaded to /home/reana/reanahub/reana-demo-root6-roofit.


Contributors
============

The list of contributors in alphabetical order:

- `Ana Trisovic <https://orcid.org/0000-0003-1991-0533>`_ <ana.trisovic@gmail.com>
- `Anton Khodak <https://orcid.org/0000-0003-3263-4553>`_ <anton.khodak@ukr.net>
- `Diego Rodriguez <https://orcid.org/0000-0003-0649-2002>`_ <diego.rodriguez@cern.ch>
- `Dinos Kousidis <https://orcid.org/0000-0002-4914-4289>`_ <dinos.kousidis@cern.ch>
- `Lukas Heinrich <https://orcid.org/0000-0002-4048-7584>`_ <lukas.heinrich@gmail.com>
- `Tibor Simko <https://orcid.org/0000-0001-7202-5803>`_ <tibor.simko@cern.ch>
