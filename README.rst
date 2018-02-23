==============================================
 Reusable analysis example - ROOT6 and RooFit
==============================================

.. image:: https://img.shields.io/travis/reanahub/reana-demo-root6-roofit.svg
   :target: https://travis-ci.org/reanahub/reana-demo-root6-roofit

.. image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

.. image:: https://img.shields.io/github/license/reanahub/reana-demo-root6-roofit.svg
   :target: https://github.com/reanahub/reana-demo-root6-roofit/blob/master/COPYING

About
=====

This repository provides a simplified particle physics analysis example for the
`REANA <http://reanahub.io/>`_ reusable research data analysis plaftorm. The
example mimics a typical particle physics analysis where the signal and
background data is processed and fitted against a model. The example will use
the `RooFit <https://root.cern.ch/roofit>`_ package of the `ROOT
<https://root.cern.ch/>`_ framework.

Making a research data analysis reproducible means to provide "runnable recipes"
addressing (1) where the input datasets are, (2) what software was used to
analyse the data, (3) which computing environment was used to run the software,
and (4) which workflow steps were taken to run the analysis.

1. Input dataset
================

In this example the signal and background data will be generated; see below.
Therefore there is no explicit input file to be taken care of.

2. Analysis code
================

Our analysis will consist of two stages. In the first stage, signal and
background are generated. In the second stage, a fit will be made for the signal
and background.

For the first generation stage, `gendata.C <gendata.C>`_ is a ROOT macro that
generates signal and background data. The code was taken from the RooFit
tutorial `rf502_wspacewrite.C
<https://root.cern.ch/root/html/tutorials/roofit/rf502_wspacewrite.C.html>`_ and
it was slightly modified. One could run it locally for 20000 events as follows::

  $ root -b -q 'gendata.C(20000,"data.root")'

Note that this generates a temporary ``data.root`` data file::

  $ ls -l data.root
  -rw-r--r-- 1 root root 153295 Jun  1 17:01 data.root

For the second fitting stage, `fitdata.C <fitdata.C>`_ is a ROOT macro that
makes a fit for the signal and the background data. The code was taken from the
RooFit tutorial `rf503_wspaceread.C
<https://root.cern.ch/root/html/tutorials/roofit/rf503_wspaceread.C.html>`_ and
it was slightly modified. One could run it locally as follows::

  $ root -b -q 'fitdata.C("data.root","plot.png")'

This generates a final plot representing the result of our analysis:

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-root6-roofit/master/docs/plot.png
   :alt: plot.png
   :align: center

Let us now try to provide runnable recipes so that our analysis can be run in a
reproducible manner on the REANA cloud.

3. Compute environment
======================

First we need to take care of expressing our runtime environment in a reusable
manner. Our example analysis is completely done within the `ROOT6
<https://root.cern.ch/>`_ analysis framework. The computing environment can be
therefore easily encapsulated by using the upstream `reana-env-root6
<https://github.com/reanahub/reana-env-root6>`_ base image. (See there how it
was created.) We can actually use this base image "as is", because our two
macros ``gendata.C`` and ``fitdata.C`` can be mounted into the container via
code volume. We don't need to create any specially customised environment.

4. Analysis workflow
====================

Secondly we need to capture the analysis workflow and the commands we have run
to obtain the final plot.

As mentioned above, the analysis workflow had two stages, the generation stage
and the fitting stage. We can represent these steps in a structured YAML manner
using the `Yadage <https://github.com/diana-hep/yadage>`_ workflow engine and `Common Workflow Language
<http://www.commonwl.org/v1.0/>`_ specification. The corresponding
workflow descriptions can be found under ``workflow/yadage/workflow.yaml`` and
``workflow/cwl/workflow.cwl`` paths.

That's all! Our example analysis is now fully described in the REANA-compatible
reusable analysis manner and is prepared to be run on the REANA cloud.

Local testing with Docker
=========================

Let us test whether everything works well locally in our containerised
environment. We shall use Docker locally. Note how we mount our local
directories ``inputs``, ``code`` and ``outputs`` into the containerised
environment:

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

Let us check whether the resulting plot is the same as the one showed in the
documentation:

.. code-block:: console

    $ diff outputs/plot.png  ./docs/plot.png

Local testing with Yadage
=========================

Let us test whether the Yadage workflow engine execution works locally.

Since Yadage only accepts one input directory as parameter, we are going to
create a wrapper directory which will contain links to ``inputs`` and ``code``
directories:

.. code-block:: console

    $ mkdir -p yadage-local-run/yadage-inputs
    $ cd yadage-local-run
    $ cp -a ../code ../inputs yadage-inputs

We can now run Yadage locally as follows:

.. code-block:: console

    $ yadage-run . ../workflow/yadage/workflow.yaml \
          -p events=20000 \
          -p gendata=code/gendata.C \
          -p fitdata=code/fitdata.C \
          -d initdir=`pwd`/yadage-inputs
    2018-02-19 16:01:34,297 - yadage.utils - INFO - setting up backend multiproc:auto with opts {}
    2018-02-19 16:01:34,299 - packtivity.asyncbackends - INFO - configured pool size to 4
    2018-02-19 16:01:34,311 - yadage.utils - INFO - local:. {u'initdir': '/home/simko/private/src/reana-demo-root6-roofit/yadage-local-run/yadage-inputs'}
    2018-02-19 16:01:34,357 - yadage.steering_object - INFO - initializing workflow with {u'gendata': 'code/gendata.C', u'fitdata': 'code/fitdata.C', u'events': 20000}
    2018-02-19 16:01:34,357 - adage.pollingexec - INFO - preparing adage coroutine.
    2018-02-19 16:01:34,357 - adage - INFO - starting state loop.
    2018-02-19 16:01:34,413 - yadage.handlers.scheduler_handlers - INFO - initializing scope from dependent tasks
    2018-02-19 16:01:34,435 - yadage.wflowview - INFO - added node <YadageNode init DEFINED lifetime: 0:00:00.000253  runtime: None (id: 23855c9fe3d01cc568e891af020be486cb0eac17) has result: True>
    2018-02-19 16:01:34,619 - yadage.wflowview - INFO - added node <YadageNode gendata DEFINED lifetime: 0:00:00.000127  runtime: None (id: 3075a77f855645a5556f5355ff66952a3c03b58f) has result: True>
    2018-02-19 16:01:34,780 - yadage.wflowview - INFO - added node <YadageNode fitdata DEFINED lifetime: 0:00:00.000128  runtime: None (id: 6908bd540badcabce2d97fa095a7772a5d577210) has result: True>
    2018-02-19 16:01:34,865 - packtivity_logger_init.step - INFO - publishing data: <TypedLeafs: {u'gendata': u'/home/simko/private/src/reana-demo-root6-roofit/yadage-local-run/yadage-inputs/code/gendata.C', u'fitdata': u'/home/simko/private/src/reana-demo-root6-roofit/yadage-local-run/yadage-inputs/code/fitdata.C', u'events': 20000}>
    2018-02-19 16:01:34,897 - adage.node - INFO - node ready <YadageNode init SUCCESS lifetime: 0:00:00.462261  runtime: 0:00:00.031310 (id: 23855c9fe3d01cc568e891af020be486cb0eac17) has result: True>
    2018-02-19 16:01:34,922 - packtivity_logger_gendata.step - INFO - starting file loging for topic: step
    2018-02-19 16:01:34,981 - packtivity_logger_gendata.step - INFO - prepare pull
    2018-02-19 16:01:39,672 - adage.node - INFO - node ready <YadageNode gendata SUCCESS lifetime: 0:00:05.053356  runtime: 0:00:04.751996 (id: 3075a77f855645a5556f5355ff66952a3c03b58f) has result: True>
    2018-02-19 16:01:39,695 - packtivity_logger_fitdata.step - INFO - starting file loging for topic: step
    2018-02-19 16:01:39,733 - packtivity_logger_fitdata.step - INFO - prepare pull
    2018-02-19 16:01:45,540 - adage.node - INFO - node ready <YadageNode fitdata SUCCESS lifetime: 0:00:10.759921  runtime: 0:00:05.846398 (id: 6908bd540badcabce2d97fa095a7772a5d577210) has result: True>
    2018-02-19 16:01:45,547 - adage.controllerutils - INFO - no nodes can be run anymore and no rules are applicable
    2018-02-19 16:01:45,547 - adage.pollingexec - INFO - exiting main polling coroutine
    2018-02-19 16:01:45,548 - adage - INFO - adage state loop done.
    2018-02-19 16:01:45,548 - adage - INFO - execution valid. (in terms of execution order)
    2018-02-19 16:01:45,555 - adage.controllerutils - INFO - no nodes can be run anymore and no rules are applicable
    2018-02-19 16:01:45,555 - adage - INFO - workflow completed successfully.

Let us check whether the resulting plot is the same as the one showed in the
documentation:

.. code-block:: console

    $ diff outputs/plot.png  ./docs/plot.png

Local testing with CWL
=========================

Let us test whether the CWL workflow execution works locally as well.

To prepare the execution, we can:

- either place input files ``code/gendata.C`` and ``code/fitdata.C`` into the directory with ``input.yml``

.. code-block:: console


    $ cp code/gendata.C code/fitdata.C workflow/cwl/


- or place ``input.yml`` to the root of the repository and edit it to correctly point to the input files:


.. code-block:: console
   :emphasize-lines: 7,10

    $ cp workflow/cwl/input.yml .
    $ vim input.yml

    events: 20000
    fitdata_tool:
      class: File
      path: code/fitdata.C
    gendata_tool:
      class: File
      path: code/gendata.C


We can now run the corresponding commands locally as follows:

.. code-block:: console

   // use this command, if input files were copied
   $ cwltool --quiet --outdir="outputs" workflow/cwl/workflow.cwl workflow/cwl/input.yml

   // or use this command, if input.yml was edited
   $ cwltool --quiet --outdir="outputs" workflow/cwl/workflow.cwl input.yml

    {
        "plot": {
            "checksum": "sha1$adc52c16836ac4cc385aab7aeddf492fe83c45e2",
            "basename": "plot.png",
            "location": "file:///path/to/reana-demo-root6-roofit/outputs/plot.png",
            "path": "/path/to/reana-demo-root6-roofit/outputs/plot.png",
            "class": "File",
            "size": 16273
        }
    }


Let us check whether the resulting plot is the same as the one showed in the
documentation:

.. code-block:: console

    $ diff outputs/plot.png  ./docs/plot.png

Create REANA file
=================

Putting all together, we can now describe our ROOT6 RooFit physics analysis
example, its runtime environment, the inputs, the code, the workflow and its
outputs by means of the following REANA specification file:

.. code-block:: yaml

    version: 0.1.0
    metadata:
      authors:
      - Ana Trisovic <ana.trisovic@gmail.com>
      - Lukas Heinrich <lukas.heinrich@gmail.com>
      - Tibor Simko <tibor.simko@cern.ch>
      title: ROOT6 and RooFit physics analysis example
      date: 19 February 2018
      repository: https://github.com/reanahub/reana-demo-root6-roofit/
    code:
      files:
      - code/gendata.C
      - code/fitdata.C
    inputs:
      parameters:
        events: 20000
        gendata: code/gendata.C
        fitdata: code/fitdata.C
    outputs:
      files:
      - outputs/plot.png
    environments:
      - type: docker
        image: reanahub/reana-env-root6
    workflow:
      type: yadage
      file: workflow/yadage/workflow.yaml

Run the example on REANA cloud
==============================

We can now install the REANA client and submit the ROOT6 RooFit analysis example
to run on some particular REANA cloud instance. We start by installing the
client:

.. code-block:: console

    $ mkvirtualenv reana-client -p /usr/bin/python2.7
    $ pip install reana-client

and connect to the REANA cloud instance where we will run this example:

.. code-block:: console

    $ export REANA_SERVER_URL=http://192.168.99.100:32658
    $ reana-client ping
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Connecting to http://192.168.99.100:32658
    [INFO] Server is running.

We can now initialise workflow and upload our ROOT macros as input code:

.. code-block:: console

    $ reana-client workflow create
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Validating REANA specification file: /home/simko/private/src/reana-demo-root6-roofit/reana.yaml
    [INFO] Connecting to http://192.168.99.100:32658
    {u'message': u'Workflow workspace created', u'workflow_id': u'3be010aa-b3b5-408c-9d16-17f0518a6995'}
    $ export REANA_WORKON=3be010aa-b3b5-408c-9d16-17f0518a6995
    $ reana-client workflow status
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Name        |UUID                                |User                                |Organization|Status
    ------------|------------------------------------|------------------------------------|------------|-------
    nervous_shaw|3be010aa-b3b5-408c-9d16-17f0518a6995|00000000-0000-0000-0000-000000000000|default     |created
    $ reana-client code upload gendata.C
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Uploading ./code/gendata.C ...
    File ./code/gendata.C was successfully uploaded.
    $ reana-client code upload fitdata.C
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Uploading ./code/fitdata.C ...
    File ./code/fitdata.C was successfully uploaded.
    $ reana-client code list
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    Name     |Size|Last-Modified
    ---------|----|--------------------------------
    fitdata.C|1648|2018-02-19 15:12:56.966400+00:00
    gendata.C|1937|2018-02-19 15:12:51.891938+00:00

Start workflow execution and enquire about its running status:

.. code-block:: console

    $ reana-client workflow start
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow `3be010aa-b3b5-408c-9d16-17f0518a6995` selected
    Workflow `3be010aa-b3b5-408c-9d16-17f0518a6995` has been started.
    [INFO] Connecting to http://192.168.99.100:32658
    {u'status': u'running', u'organization': u'default', u'message': u'Workflow successfully launched', u'user': u'00000000-0000-0000-0000-000000000000', u'workflow_id': u'3be010aa-b3b5-408c-9d16-17f0518a6995'}
    Workflow `3be010aa-b3b5-408c-9d16-17f0518a6995` has been started.
    $ reana-client workflow status
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Name         |UUID                                |User                                |Organization|Status
    -------------|------------------------------------|------------------------------------|------------|-------
    naughty_gates|3be010aa-b3b5-408c-9d16-17f0518a6995|00000000-0000-0000-0000-000000000000|default     |running
    $ reana-client workflow status
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Name          |UUID                                |User                                |Organization|Status
    --------------|------------------------------------|------------------------------------|------------|--------
    pensive_carson|3be010aa-b3b5-408c-9d16-17f0518a6995|00000000-0000-0000-0000-000000000000|default     |finished

After the workflow execution successfully finished, we can retrieve its output:

.. code-block:: console

    $ reana-client outputs list
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] Workflow "3be010aa-b3b5-408c-9d16-17f0518a6995" selected
    Name                                 |Size  |Last-Modified
    -------------------------------------|------|--------------------------------
    gendata/data.root                    |153468|2018-02-19 15:17:16.154741+00:00
    fitdata/plot.png                     |16273 |2018-02-19 15:17:16.154741+00:00
    _yadage/yadage_snapshot_backend.json |773   |2018-02-19 15:17:16.154741+00:00
    _yadage/yadage_snapshot_workflow.json|12426 |2018-02-19 15:17:16.154741+00:00
    _yadage/yadage_template.json         |1817  |2018-02-19 15:17:16.154741+00:00
    $ reana-client outputs download fitdata/plot.png
    [INFO] REANA Server URL ($REANA_SERVER_URL) is: http://192.168.99.100:32658
    [INFO] fitdata/plot.png binary file downloaded ... writing to ./outputs/
    File fitdata/plot.png downloaded to ./outputs/

Let us check whether the resulting plot is the same as the one showed in the
documentation:

.. code-block:: console

    $ ls -l outputs/fitdata/plot.png
    -rw-r--r-- 1 simko simko 16273 Feb 19 16:18 outputs/fitdata/plot.png
    $ diff outputs/fitdata/plot.png ./docs/plot.png

The following example uses Yadage workflow engine. If you would like to use CWL workflow engine,
please just use ``-f reana-cwl.yaml`` with reana-client commands

Thank you for using the `REANA <http://reanahub.io/>`_ reusable analysis
platform.
