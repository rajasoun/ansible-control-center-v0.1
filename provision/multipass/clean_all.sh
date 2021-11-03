#!/usr/bin/env bash

multipass ls | grep -v Name | awk '{print $1}' | xargs multipass delete
multipass purge