#!/usr/bin/python

from lxml import etree
import sys, re, requests, json, urllib2, time

spark_master = sys.argv[1]
html = urllib2.urlopen("http://" + spark_master + ":8080/").read()

root = etree.fromstring(html)
rows = root.xpath('/html/body/div/div[5]/div/div/table/tbody/tr')

if len(rows) == 0:
	print "There is no running jobs to kill"
else:
	for e in rows:
		driver_to_kill = e.find('td').text.strip()
		print "Killing " + driver_to_kill
		result = requests.post("http://" + spark_master + ":6066/v1/submissions/kill/" + driver_to_kill)
		print json.dumps(json.loads(result.text), indent=4)

	print "Waiting for 10 seconds before verifying ..."

	time.sleep(10)
	# verifying that everything is terminated
	html = urllib2.urlopen("http://" + spark_master + ":8080/").read()

	root = etree.fromstring(html)
	rows = root.xpath('/html/body/div/div[5]/div/div/table/tbody/tr')

	if len(rows) == 0:
		print "every spark job has been terminated"
	else:
		print "Unable to kill all Spark jobs at once"
