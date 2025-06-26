from pathlib import Path
import lxml.etree as ET

input_dir = Path("Corpus")
output_dir = input_dir / "cleaned"
output_dir.mkdir(parents=True, exist_ok=True)

def remove_namespace(file_in, file_out):
    parser = ET.XMLParser(remove_blank_text=True)
    tree = ET.parse(str(file_in), parser)
    for elem in tree.getroot().iter():
        if isinstance(elem.tag, str) and elem.tag.startswith("{"):
            elem.tag = elem.tag.split("}", 1)[1]
    ET.cleanup_namespaces(tree)
    tree.write(str(file_out), encoding="utf-8", xml_declaration=True, pretty_print=True)

for xml_file in input_dir.glob("*.xml"):
    cleaned_file = output_dir / xml_file.name
    try:
        remove_namespace(xml_file, cleaned_file)
        print(f"✓ {xml_file.name} bereinigt.")
    except Exception as e:
        print(f"⚠️ Fehler in {xml_file.name}: {e}")
