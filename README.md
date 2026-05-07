![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)

# 🖥 sysmon — System Monitor

Narzędzie terminalowe do monitorowania zasobów systemu (CPU, RAM, dysk) napisane w Bashu.

## Użycie

```bash
./sysmon.sh              # jednorazowy snapshot
./sysmon.sh --watch      # live monitoring co 5 sekund
./sysmon.sh --alert 80   # alert gdy metryka > 80%
./sysmon.sh --report     # zapisz raport do pliku
```

## Funkcje

- Kolorowy output (zielony/żółty/czerwony zależnie od obciążenia)
- Live monitoring z automatycznym odświeżaniem
- System alertów z konfigurowalnym progiem
- Zapis raportów do pliku z timestampem
- Obsługa błędów z pomocą użycia

## Wymagania

- macOS (testowane na macOS Sequoia)
- Bash 3.2+