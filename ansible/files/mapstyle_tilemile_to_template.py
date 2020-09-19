#!/usr/bin/python3
import json, os

projectDir = '/home/importeur/Documents/MapBox/project/falschparker'

with open(os.path.join(projectDir, 'project.mml'), 'r') as f:
  data = json.load(f)

print(data);

with open(os.path.join(projectDir, 'project.mml.j2'), 'w') as f:
  json.dump(data, f, indent=2)
