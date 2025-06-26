from pathlib import Path
from lxml import etree
import pandas as pd

# folder containing all plays without namespace (->cleaned)
tei_dir = Path("/Users/Computer/Documents/Studium/Master/4. Semester/Text Technology/Projekt/Corpus/cleaned")
records = []

def count_words(text):
    return len(text.split())

for file_path in tei_dir.glob("*.xml"):
    try:
        tree = etree.parse(str(file_path))
        play_title = file_path.stem

        # build gender map (from listPerson)
        gender_map = {}
        for person in tree.findall(".//listPerson/person"):
            pid = person.get("{http://www.w3.org/XML/1998/namespace}id")
            sex = person.get("sex", "UNKNOWN")
            if pid:
                gender_map[f"#{pid}"] = sex.upper()

        # analyse all <sp>-blocks 
        for sp in tree.findall(".//sp"):
            who_raw = sp.get("who")
            if not who_raw:
                continue
            speakers = who_raw.strip().split()
            text = " ".join(sp.xpath(".//p//text()"))
            total_words = count_words(text)
            words_per_speaker = total_words // len(speakers) if speakers else 0

            for who in speakers:
                records.append({
                    "play": play_title,
                    "character_id": who,
                    "gender": gender_map.get(who, "UNKNOWN"),
                    "words": words_per_speaker
                })

    except Exception as e:
        print(f"⚠️ Fehler bei {file_path.name}: {e}")

# summarise
df = pd.DataFrame(records)
summary = df.groupby(["play", "character_id", "gender"]).agg(
    num_speeches=("words", "count"),
    total_words=("words", "sum"),
    avg_words_per_speech=("words", "mean")
).reset_index()

# save
output_csv = tei_dir.parent / "speaker_summary_split.csv"
summary.to_csv(output_csv, index=False)
print(f"✓ Datei gespeichert: {output_csv}")
