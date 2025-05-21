#!/bin/bash
echo "Using pre-built Flutter web files"
echo "Copying files from build/web to publish directory"
cp -r build/web/* .
