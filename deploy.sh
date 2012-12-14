#!/usr/bin/env bash
for server in "$@"; do
	ssh $server	< fetch.sh
done