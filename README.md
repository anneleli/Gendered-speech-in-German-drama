# Welcome to my project "Gendered Speech Patterns in German Drama: A TEI-Based Graph Analysis"

## Project goal: 
Investigate speech distribution among female and male speakers in order to visualize and explore patterns of speech, dominance, and character relationships across texts

## Related research questions:
- Do male characters speak more than female characters in the plays examined?
- Are there plays with a balanced proportion of speech?
- Which character is dominant in a particular play?

## What you will find in this repository
- Code: remove_namespaces.py (XML cleanup script)
        speeches_analysis.py (analysis of speech amount, e.g. total words per character)
- Corpus: raw TEI files from DraCor
- Corpus_cleaned: namespace-free TEI files
- speaker_summary_split.csv: CSV with speaker data

## Technologies Used
- Python (`lxml`, `pandas`)
- TEI-XML (DraCor corpus)
- Neo4j (Cypher, APOC)
- XPath

## Workflow
1. Collect: Selection of balanced plays (equal number of female/male speakers) from German DraCor
2. Prepare: Namespace removal + speech extraction from TEI
3. Access: Import into Neo4j + visual exploration
