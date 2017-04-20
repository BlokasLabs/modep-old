#!/usr/bin/python

import requests
import json
import sys
import os

if len(sys.argv) != 2 and len(sys.argv) != 3:
	exit(1)

SERVER_URI         = "http://localhost:80/"

LOCAL_STORAGE      = os.path.expanduser("~/.modep/")
LAST_PEDALBOARD    = LOCAL_STORAGE + "last_board"
DEFAULT_PEDALBOARD = "/root/.pedalboards/default.pedalboard" # /usr/local/modep/.pedalboards

if not os.path.exists(LOCAL_STORAGE):
	try:
		os.makedirs(LOCAL_STORAGE)
	except:
		print("Failed to create directory for local state storage")
		exit(1)

def get_last_pedalboard():
	try:
		return open(LAST_PEDALBOARD, "rt").read()
	except:
		return ""

def set_last_pedalboard(board):
	try:
		open(LAST_PEDALBOARD, "wt").write(board)
	except:
		print("Failed to set last pedalboard")
		pass

def set_pedalboard(board):
	try:
		requests.get(SERVER_URI + "reset")
		requests.post(SERVER_URI + "pedalboard/load_bundle/?bundlepath=%s" % board)
	except:
		print("Setting to pedalboard %s failed." % board)

def set_default_pedalboard():
	try:
		requests.get(SERVER_URI + "reset")
		requests.post(SERVER_URI + "pedalboard/load_bundle/?bundlepath=%s&isDefault=1" % DEFAULT_PEDALBOARD)
	except:
		print("Failed to set default pedalboard.")

def get_pedalboards(bank_id):
	result = []

	try:
		r = requests.get(SERVER_URI + "banks/")

		if r.status_code == 200:
			j = json.loads(r.content)
			for i in j[bank_id]["pedalboards"]:
				result.append(i["bundle"])
	finally:
		return result

def get_current_pedalboard():
	try:
		r = requests.get(SERVER_URI + "pedalboard/current")
		if r.status_code == 200:
			if r.content == DEFAULT_PEDALBOARD:
				return ""
			else:
				return r.content
		else:
			print("Failed getting current board with err %u" % r.status_code)
	except:
		return ""

def get_current_pedalboard_index(pedalboards, current):
	try:
		return pedalboards.index(current)
	except:
		return -1

def load_next():
	boards = get_pedalboards(0)
	if len(boards) == 0:
		print("No banks or pedalboards!")
		return
	currentName = get_current_pedalboard()
	current = get_current_pedalboard_index(boards, currentName)
	next = (current + 1) % len(boards)
	print("Switching %s -> %s" % (currentName, boards[next]))
	set_pedalboard(boards[next])

def load_prev():
	boards = get_pedalboards(0)
	if len(boards) == 0:
		print("No banks or pedalboards!")
		return
	currentName = get_current_pedalboard()
	current = get_current_pedalboard_index(boards, currentName)
	if current == -1:
		prev = 0
	else:
		prev = (current + len(boards) - 1) % len(boards)
	print("Switching %s -> %s" % (currentName, boards[prev]))
	set_pedalboard(boards[prev])

def load_index(index):
	boards = get_pedalboards(0)
	if len(boards) == 0:
		print("No banks or pedalboards!")
		exit(1)

	if index < 0 or index >= len(boards):
		print("Index %d is out of range!" % index)
		exit(1)

	set_pedalboard(boards[index])

def bypass_toggle():
	currentName = get_current_pedalboard()

	if currentName:
		# Not in bypass state
		print ("Storing %s, switching to default board." % currentName)
		set_last_pedalboard(currentName)
		set_default_pedalboard()
	else:
		b = get_last_pedalboard()
		if b:
			print("Restoring %s board from default board." % b)
			set_pedalboard(b)
		else:
			print("Didn't find any stored board")

if sys.argv[1] == "next":
	load_next()
elif sys.argv[1] == "prev":
	load_prev()
elif sys.argv[1] == "bypass":
	bypass_toggle()
elif sys.argv[1] == "list":
	print("list")
	for board in get_pedalboards(0):
		print(board)
elif sys.argv[1] == "index":
	load_index(int(sys.argv[2]))
