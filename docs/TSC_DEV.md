# TSC-DEV-publicatie

Versie 0.2.1 is technisch voorbereid als Toon Store-pakket. De installatie bewaart
`/mnt/data/tsc/mhi.json` en laat het afzonderlijke ESPHome-sleutelbestand ongemoeid,
zodat ingestelde airco's en stabiele unit-ID's bij een update niet worden vervangen.

## Publicatiestappen

1. Voer `scripts/package.sh` uit en bewaar de gemelde SHA-256.
2. Maak/tag release `0.2.1` in `ToonSoftwareCollective/mhi` met de map `mhi` uit het archief.
3. Voeg `ToonRepo-entry.xml` toe aan de DEV-catalogus van `toonstore_AppRepository`.
4. Installeer vanuit TSC-DEV op een schone Toon 2 en controleer WF-RAC en ESPHome afzonderlijk.

De plugin-keuze staat in de app. De driverbestanden worden uit de ingestelde
MHI-plugin-catalogus opgehaald; de kernapp bevat geen persoonlijke IP-adressen,
accountgegevens of ESPHome-sleutels.
