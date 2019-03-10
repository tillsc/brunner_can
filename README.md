Brunner CAN IDs
====

Dieses Repository enthält eine Liste der per reverse engineering ermittelten 
CAN-Bus-Nachrichten und Singale der Brunner BHZ3 sowie der Brunner EOS7.

Aus praktischen Gründen sind diese in einer UTF-8 codierten CSV-Datei dokumentiert.

### Converter

Dazu gibt es ein kleines Ruby-Script, das dieses CSV in mehrere [DBC](http://socialledge.com/sjsu/index.php/DBC_Format)-Dateien konvertieren kann. Es erzeugt zusätzlich Konfigurations-Schnipsel für [Home Assistant](https://www.home-assistant.io/hassio/), um die Signale dort per MQTT (siehe https://github.com/tillsc/can2mqtt) wieder einzubinden.
)

    ruby converter.rb

