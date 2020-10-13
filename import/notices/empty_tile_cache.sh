#!/bin/bash
# This script should be run as root, after import to database finished.
id
su renderd -c 'id; /bin/rm -Rf /var/lib/mod_tile/falschparker/default/*; touch /var/lib/mod_tile/falschparker/planet-import-complete'
