#!/bin/bash
projectDir='/home/importeur/Documents/MapBox/project/falschparker'
./mapstyle_tilemill_to_template.py <$projectDir/project.mml >$projectDir/project.mml.j2
