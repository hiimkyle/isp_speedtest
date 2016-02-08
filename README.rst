ISP Speedtest
=============

Introduction
------------
This script is designed to run automated speed tests and output their measurements
into a Splunk-digestable log file. I have also included a sample dashboard for
Splunk to get you started. This is an adaptation of the original idea below.

Original idea: http://makezine.com/projects/send-ticket-isp-when-your-internet-drops/


Pre-reqs
--------
- speedtest_cli
- splunk
- raspberry pi w/ splunk forwarder


speedtest-cli Installation
--------------------------
See: https://github.com/sivel/speedtest-cli/blob/master/README.rst


Splunk Installation
-------------------
See: http://docs.splunk.com/Documentation/Splunk/latest/Installation/InstallonLinux


Splunk Pi Forwarder
-------------------
See https://splunkbase.splunk.com/app/1611/


Script Installation
-------------------
This script includes two componenents:

1. Script that runs the speedtests

2. A cron job that runs the script automatically


speedtest-splunk.sh
~~~~~~~~~~~~~~~~~~~
1. Place the script in its permanent location

- This example uses /usr/bin as its location.

2. Determine where you want the logs stored

- This example uses /var/log/speedtest

3. Determine how frequently you want the tests to run

- This example uses every 15 minutes


crontab
~~~~~~~
Set your crontab to run the script automatically

   ``crontab -e``
   
   ``*/15 *  * * *   root    /usr/bin/speedtest-splunk.sh``
    

Splunk Configuration
--------------------
You will need configure your Splunk instance to index the data correctly.
For this, your indexer will need a new index to contain this data. If you
know what you are doing, you can change this index or skip it entirely.

For this example, we will create an index called *speedtest*.  

indexes.conf
~~~~~~~~~~~~
Example included in splunk/idx/indexes.conf

- Add the text in this file to /opt/splunk/etc/system/local/indexes.conf

Splunk Pi Configuration
------------------------
You will need to configure your Pi forwarder to look for the speedtest data.
The forwarder will need to be installed before continuing.

inputs.conf
~~~~~~~~~~~
Example included in splunk/pi/inputs.conf

- Add the text in this file to /opt/splunkforwarder/etc/system/local/inputs.conf


Next Steps
----------

Verify data
~~~~~~~~~~

1. Run the script manually or wait for for the cron job to run.

2. Log into Splunk and verify that data is being indexed. Use the search below.

   ``index=speedtest``

NOTE: If you don't see data, verify your forwarder and indexer configurations.


Dashboard
~~~~~~~~~
The included dashboard includes a few basic metrics to get started. To import
it, simply create a new XML file in the search app. 

Example included in splunk/idx/isp_healthcheck.xml

- In this example, place the file below on the indexer in the directory 
  
  ``/opt/splunk/etc/apps/search/local/data/ui/views``


