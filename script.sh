#!/bin/bash

echo "add ids"
add-attributes -g "./app/data/letters/*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/bahrschnitzler/letters"
add-attributes -g "./app/data/indices/list*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/bahrschnitzler/indices"
add-attributes -g "./app/data/meta/E*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/bahrschnitzler/meta"
add-attributes -g "./app/data/diaries/D*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/bahrschnitzler/diaries"
add-attributes -g "./app/data/texts/T*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/bahrschnitzler/texts"