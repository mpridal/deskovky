# Požadavky Sirek na framework

## 1. Události z tahu, který ukončí partii (stejné jako Piškvorky, bod 2)

**Co:** herní obrazovka zkopíruje události z desky hned po posledním tahu, dřív než deska dostane nový stav. Sirky prohrává ten, kdo táhne naposled, takže výhru vždy „způsobí“ soupeř.

**Dočasně:** deska hlásí výhru už ve chvíli, kdy je rozhodnutá (zbývá jediná sirka), a při vlastním tahu ještě před odesláním. Výhra se nepřipíše jen tehdy, když soupeř na **jiném zařízení** vezme naráz několik posledních sirek (robot to nikdy neudělá).

**Navržené API:** `GameModule.finalEvents(S state)` – framework ho zavolá při konci partie a přidá výsledek k událostem z desky (`MatchesEvents.of(state)` by šlo použít přímo).
