#!/bin/bash

echo "add ids"
# add-attributes -g "./app/data/letters/*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/barhschnitzler/letters"
# add-attributes -g "./app/data/indices/list*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/barhschnitzler/indices"
# add-attributes -g "./app/data/meta/E*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/barhschnitzler/meta"
# add-attributes -g "./app/data/diaries/D*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/barhschnitzler/diaries"
add-attributes -g "./app/data/texts/T*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/barhschnitzler/texts"