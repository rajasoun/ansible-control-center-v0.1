#!/usr/bin/env bash
multipass ls | grep -v Name | awk '{print $1}' | xargs multipass stop
multipass ls | grep -v Name | awk '{print $1}' | xargs multipass delete
multipass purge
rm -fr config/cloud-init.yaml config/createusers.yal inventory
