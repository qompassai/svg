from xml.etree import ElementTree as ET

def change_svg_fill(svg_path: str, fill_color: str = "white", output_path: str = None):
    tree = ET.parse(svg_path)
    root = tree.getroot()
    
    ns = {'svg': 'http://www.w3.org/2000/svg'}
    
    for elem in root.findall('.//svg:path', ns) + root.findall('.//svg:rect', ns):
        elem.set('fill', fill_color)
    
    output_file = output_path or svg_path
    tree.write(output_file, encoding='utf-8', xml_declaration=True)
    print(f"Updated SVG fill set to {fill_color} for {output_file}")

change_svg_fill('monero-qr.svg', '#7DF9FF', 'monero-qr-blue.svg')

