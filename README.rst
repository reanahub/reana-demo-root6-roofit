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

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-root6-roofit/master/plot.png
   :alt: plot.png
   :align: center

Let us now try to provide runnable recipes so that our analysis can be run in a
reproducible manner on the REANA cloud.

3. Compute environment
======================

First we need to take care of expressing our runtime environment in a reusable
manner.

Our example analysis was done completely within the `ROOT6
<https://root.cern.ch/>`_ analysis framework. The computing environment can be
therefore easily encapsulated starting from the `reana-env-root6
<https://github.com/reanahub/reana-env-root6>`_ base image (providing ROOT6) and
adding our two macros ``gendata.C`` and ``fitdata.C`` on top. This gives the
following ``Dockerfile``::

  FROM reanahub/reana-env-root6
  WORKDIR /code
  ADD gendata.C gendata.C
  ADD fitdata.C fitdata.C

A container image for our analysis can be built as follows::

  $ docker build -t johndoe/reana-demo-root6-roofit .
  $ docker push johndoe/reana-demo-root6-roofit

4. Analysis workflow
====================

Secondly we need to capture the analysis workflow and the commands we have run
to obtain the final plot.

As mentioned above, the analysis workflow had two stages, the generation stage
and the fitting stage. Using the `Yadage <https://github.com/diana-hep/yadage>`_
workflow engine, we can represent these steps in a structured YAML manner as
follows::

  $ cat workflow.yml
  stages:
    - name: gendata
      dependencies: ['init']
      scheduler:
        scheduler_type: singlestep-stage
        parameters:
          events: {stages: init, output: events, unwrap: true}
          outfilename: '{workdir}/data.root'
        step: {$ref: 'steps.yml#/gendata'}
    - name: fitdata
      dependencies: ['gendata']
      scheduler:
        scheduler_type: singlestep-stage
        parameters:
          data: {stages: gendata, output: data, unwrap: true}
          outfile: '{workdir}/plot.png'
        step: {$ref: 'steps.yml#/fitdata'}

where each step is defined as::

  $ cat steps.yml
  gendata:
    process:
      process_type: 'interpolated-script-cmd'
      script: root -b -q 'gendata.C({events},"{outfilename}")'
    publisher:
      publisher_type: 'frompar-pub'
      outputmap:
        data: outfilename
    environment:
      environment_type: 'docker-encapsulated'
      image: johndoe/reana-demo-root6-roofit

  fitdata:
    process:
      process_type: 'interpolated-script-cmd'
      script: root -b -q 'fitdata.C("{data}","{outfile}")'
    publisher:
      publisher_type: 'frompar-pub'
      outputmap:
        plot: outfile
    environment:
      environment_type: 'docker-encapsulated'
      image: johndoe/reana-demo-root6-roofit

That's all! Our example analysis is now fully described in the REANA-compatible
reusable analysis manner and is prepared to be run on the REANA cloud.

Run the example on REANA cloud
==============================

We can now install the REANA client and submit the ``reana-demo-root6-roofit``
analysis example to run on some particular REANA cloud instance:

.. code-block:: console

   $ pip install reana-client
   $ export REANA_SERVER_URL=https://reana.cern.ch
   $ reana-client run workflow.yml
   [INFO] Starting reana-demo-root6-roofit analysis...
   [...]
   [INFO] Done. You can see the results in the `output/` directory.

**FIXME** The ``reana-client`` package is a not-yet-released work-in-progress.
Until it is available, you can use ``reana run
reanahub/reana-demo-rot6-roofit`` on the REANA server side, following the
`REANA getting started
<http://reana.readthedocs.io/en/latest/gettingstarted.html>`_ documentation.
