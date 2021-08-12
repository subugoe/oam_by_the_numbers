## Normalisierung OAM Zeitschriften (Hybrid)

### Ziele

- Main-Liste aller hybriden Journale aus Transformationsverträgen deutscher Konsortien (OAM-Liste)
- Indikatoren zum a) Transformationsgrad und b) Metadatenabdeckung auf Basis von Crossref (ggf. Unpaywall) mittels Big Query (OAM Analytics)

### Deliverables

- Blog Post
- Galerie für Neukonzeption Dashboard (idealerweise als static pages, kein Shiny)

### Stand

#### OAM-Liste

- [x] Überführung in ein Spreadsheet und Anreicherung mit ISSN-Varianten und ISSN-L
- [x] Fehlende ISSNs ergänzt (rund 40)
- [x] Falschzuordnungen berichtigt
- [ ] Duplikate bereinigen (mehr als eine ISSN-L je Titel, rund 40 Titel)
- [ ] Mapping ESAC Registry und GEPRIS (DFG-Förderung)

#### OAM Analytics

- [x] SQL-Abfrage Publikationsvolumen 
- [x] SQL-Abfrage OA-Indikatoren Unpaywall
- [ ] SQL-Abfrage CC-Lizenzen Crossref
- [ ] SQL-Abfrage Metadatenabdeckung

#### Galerie 

(angelehnt an https://glin.github.io/reactable/index.html)

- [Portfolio-Überblick](https://subugoe.github.io/oam_by_the_numbers/react_playground.html) {reactable}
- [Journal-level Sicht](https://subugoe.github.io/oam_by_the_numbers/react_jn.html) {reactable}, {crosstalk}
