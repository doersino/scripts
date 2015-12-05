#!/usr/bin/env python

# Clone or update a user's public gists.
# Usage: backup_gists.py USERNAME [DIR]

import json
from subprocess import call
from urllib import urlopen
import os
import sys

if len(sys.argv) < 2:
	raise SystemExit("Usage: backup_gists.py USERNAME [DIR]")
user = sys.argv[1]
startd = os.getcwd()
if len(sys.argv) == 3:
	startd = os.path.join(os.path.abspath(os.getcwd()), sys.argv[2])
	if not os.path.isdir(startd):
		os.mkdir(startd)

u = urlopen('https://api.github.com/users/' + user + '/gists')
gists = json.load(u)

for gist in gists:
	gistd = os.path.join(startd, gist['id'])
	if os.path.isdir(gistd):
		os.chdir(gistd)
		call(['git', 'pull', 'git://gist.github.com/' + gist['id'] + '.git'])
	else:
		os.chdir(startd)
		call(['git', 'clone', 'git://gist.github.com/' + gist['id'] + '.git'])
