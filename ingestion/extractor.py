# ingestion/extractor.py
import pandas as pd
import re
import pdfplumber
import ftfy

def _normalize(text: str) -> str:
    return ftfy.fix_text(text) if text else text

def _extract_lines(pdf_path: str) -> tuple[list, int]:
    """Extract text lines and page count from a PDF."""
    with pdfplumber.open(pdf_path) as pdf:
        num_pages = len(pdf.pages)
        page = pdf.pages[0]
        words = page.extract_words(x_tolerance=3, y_tolerance=3, keep_blank_chars=True)

    word_data = sorted(
        [{"text": w["text"], "x": w["x0"], "y": w["top"], "x1": w["x1"], "y1": w["bottom"]} for w in words],
        key=lambda w: (w["y"], w["x"])
    )

    lines = []
    current_line = []
    current_y = None

    for word in word_data:
        if current_y is None or abs(word["y"] - current_y) < 5:
            current_line.append(word)
            current_y = word["y"]
        else:
            lines.append(" ".join(w["text"] for w in sorted(current_line, key=lambda x: x["x"])))
            current_line = [word]
            current_y = word["y"]

    if current_line:
        lines.append(" ".join(w["text"] for w in sorted(current_line, key=lambda x: x["x"])))

    return lines, num_pages


def _parse_lines(lines: list, num_pages: int) -> dict:
    """Parse extracted lines into a structured form_data dict."""
    form_data = {
        "num_pages": num_pages,
        "medio_contacto": None,
        "codigo_numero": None,
        "codigo_letras": None,
        "total_llamadas": None,
        "llamante_sexo": None,
        "llamante_edad": None,
        "llamante_estado_civil": None,
        "llamante_convive": None,
        "llamante_asiduidad": None,
        "llamante_problema": None,
        "llamante_naturaleza": None,
        "llamante_inicio": None,
        "llamante_actitud_orientador": None,
        "llamante_presentacion": None,
        "llamante_paralenguaje": None,
        "llamante_procedencia": None,
        "llamante_peticion": None,
        "llamante_actitud_problema": None,
        "llamante_llamada_derivada": None,
        "tercero_sexo": None,
        "tercero_edad": None,
        "tercero_estado_civil": None,
        "tercero_convive": None,
        "tercero_relacion": None,
        "tercero_problema": None,
        "tercero_actitud_problema": None,
        "llamada_hora": None,
        "llamada_fecha": None,
        "llamada_resultado": None,
        "llamada_duracion": None,
        "entrevista_clave": None,
        "entrevista_referencia": None,
        "entrevista_hora": None,
        "entrevista_fecha": None,
        "orientador_clave_letras": None,
        "orientador_clave_numero": None,
        "orientador_nivel_ayuda": None,
        "orientador_sentimientos": None,
        "orientador_autoevaluacion": None,
        "orientador_actitudes_equivocadas": None,
        "orientador_satisfaccion_llamante": None,
        "sintesis": None,
    }

    full_text = "\n".join(lines)

    # Detect ORIENTADOR section
    in_orientador_section = False
    orientador_start_index = -1
    for i, line in enumerate(lines):
        if "ORIENTADOR" in line and not any(c.isdigit() for c in line):
            in_orientador_section = True
            orientador_start_index = i
            break

    # Line-by-line parsing
    for i, line in enumerate(lines):
        if any(f in line for f in ["1.Sexo", "2.Edad", "3.E. civil", "4.Convive", "5.Asiduidad"]):
            for pattern, field in [
                (r"1\.Sexo\s+(\d+)(?:\s+2\.|$)", "llamante_sexo"),
                (r"2\.Edad\s+(\d+)(?:\s+3\.|$)", "llamante_edad"),
                (r"3\.E\.\s*civil\s+(\d+)(?:\s+4\.|$)", "llamante_estado_civil"),
                (r"4\.Convive\s+(\d+)(?:\s+5\.|$)", "llamante_convive"),
                (r"5\.Asiduidad\s+(\d+)(?:\s|$)", "llamante_asiduidad"),
            ]:
                m = re.search(pattern, line)
                if m:
                    form_data[field] = m.group(1)

        if "6.Problema" in line:
            problema_part = line.split("6.Problema")[1]
            matches = re.findall(r"([A-Z])\s+(\d+)", problema_part)
            if matches:
                form_data["llamante_problema"] = " ".join(f"{l} {n}" for l, n in matches)
            for pattern, field in [
                (r"7\.Naturaleza\s+(\d+)(?:\s+8\.|$)", "llamante_naturaleza"),
                (r"8\.\s*Inicio\s+(\d+)(?:\s|$)", "llamante_inicio"),
            ]:
                m = re.search(pattern, line)
                if m:
                    form_data[field] = m.group(1)

        if any(f in line for f in ["9.Actitud ante el orientador", "10.Presentación", "11.Paralenguaje"]):
            for pattern, field in [
                (r"9\.Actitud ante el orientador\s+(\d+)(?:\s+10\.|$)", "llamante_actitud_orientador"),
                (r"10\.Presentación\s+(\d+)(?:\s+11\.|$)", "llamante_presentacion"),
                (r"11\.Paralenguaje\s+(\d+)(?:\s|$)", "llamante_paralenguaje"),
            ]:
                m = re.search(pattern, line)
                if m and m.group(1) not in ("10", "11"):
                    form_data[field] = m.group(1)

        if any(f in line for f in ["12.Procedencia", "13.Petición", "15.Actitud ante problema"]):
            m = re.search(r"12\.Procedencia\s+(\d+)(?:\s+13\.|$)", line)
            if m and m.group(1) != "13":
                form_data["llamante_procedencia"] = m.group(1)

            if "13.Petición" in line:
                m = re.search(r"13\.Petición\s+(\d+(?:\s+\d+)*?)(?:\s+15\.|$)", line)
                if m and m.group(1).strip() != "15":
                    form_data["llamante_peticion"] = m.group(1).strip()
                else:
                    m = re.search(r"13\.Petición\s+(\d+(?:\s+\d+)*)$", line)
                    if m:
                        form_data["llamante_peticion"] = m.group(1).strip()

            m = re.search(r"15\.Actitud ante problema\s+(\d+)(?:\s|$)", line)
            if m:
                form_data["llamante_actitud_problema"] = m.group(1)

        if "21.Problema" in line:
            matches = re.findall(r"([A-Z])\s+(\d+)", line.split("21.Problema")[1])
            if matches:
                form_data["tercero_problema"] = " ".join(f"{l} {n}" for l, n in matches)

        if "27.Clave" in line:
            m = re.search(r"27\.Clave\s+([A-Z]+)\s+([A-Z]+)\s+(\d+)", line)
            if m:
                form_data["entrevista_clave"] = f"{m.group(1)} {m.group(2)} {m.group(3)}"

        if "28.Referencia" in line:
            m = re.search(r"28\.Referencia\s+(\d+)\s+([A-Z]+)", line)
            if m:
                form_data["entrevista_referencia"] = f"{m.group(1)} {m.group(2)}"

        if "32.Nivel de Ayuda" in line:
            m = re.search(r"32\.Nivel de Ayuda\s+([\d\s]+?)(?=\s*33\.|$)", line)
            if m:
                numbers = re.findall(r"\d+", m.group(1))
                if numbers:
                    form_data["orientador_nivel_ayuda"] = " ".join(numbers)

        if "33.Sentimientos" in line:
            numbers = re.findall(r"(\d+)", line.split("33.Sentimientos")[1])
            if numbers:
                form_data["orientador_sentimientos"] = " ".join(numbers[:2])

        if "A ui c v t o it c u a d d e" in line:
            numbers = re.findall(r"\d+", line)
            if len(numbers) > 4:
                form_data["orientador_actitudes_equivocadas"] = numbers[4]

        if "cción del" in line:
            numbers = re.findall(r"\d+", line)
            if numbers:
                form_data["orientador_satisfaccion_llamante"] = numbers[-1]

        if in_orientador_section and i > orientador_start_index and "Clave" in line:
            clave_letters = []
            clave_number = None

            # Check line before for letter codes (e.g. "ME")
            if i > 0:
                prev_line = lines[i - 1].strip()
                tokens = prev_line.split()
                for token in tokens:
                    if re.match(r"^[A-Z]{1,3}$", token):
                        clave_letters.append(token)

            # Extract tokens after "Clave" but stop at first field marker (e.g. "32.")
            after_clave = line.split("Clave")[1]
            after_clave = re.split(r'\d+\.', after_clave)[0]  # stop before "32.Nivel..."
            for token in after_clave.split():
                if token == '\xa0':
                    continue
                if re.match(r"^[A-Z]{1,3}$", token):
                    clave_letters.append(token)

            # Number is on the next line
            if i + 1 < len(lines):
                next_line = lines[i + 1].strip()
                if re.match(r"^\d+$", next_line):
                    clave_number = next_line

            if clave_letters:
                form_data["orientador_clave_letras"] = " ".join(clave_letters)
            if clave_number:
                form_data["orientador_clave_numero"] = clave_number
                    
    # Standard regex patterns against full text
    patterns = {
        "medio_contacto": r"0\.Medio de contacto\s+(\d+)",
        "codigo_numero": r"Código\s+(\d+)",
        "codigo_letras": r"Código\s+\d+\s+([A-Z]+)",
        "total_llamadas": r"Total llamadas de centro:\s+(\d+)",
        "llamante_llamada_derivada": r"37\.Llamada derivada\s+(\d+)",
        "tercero_sexo": r"16\.Sexo\s+(\d+)",
        "tercero_edad": r"17\.Edad\s+(\d+)",
        "tercero_estado_civil": r"18\.E\.\s*civil\s+(\d+)",
        "tercero_convive": r"19\.Convive\s+(\d+)",
        "tercero_relacion": r"20\.Relación\s+(\d+)",
        "tercero_actitud_problema": r"22\.Actitud ante problema\s+(\d+)",
        "llamada_hora": r"23\.Hora\s+([\d:]+)",
        "llamada_fecha": r'24\.Fecha\s+([\d/]+)',
        "llamada_resultado": r"25\.Resultado\s+(\d+)",
        "llamada_duracion": r"26\.Duración\s+(\d+)",
        "entrevista_hora": r"29\.Hora\s+([\d:]+)",
        "entrevista_fecha": r'30\.Fecha\s+([\d/]+)',
        "orientador_autoevaluacion": r"34\.Autoevaluación\s+(\d+)",
    }
    for field, pattern in patterns.items():
        m = re.search(pattern, full_text, re.MULTILINE)
        if m:
            form_data[field] = m.group(1)

    # SINTESIS extraction
    sintesis_text = []
    capture_sintesis = False
    for line in lines:
        if "Guardar ficha" in line:
            break
        if capture_sintesis and line.strip():
            if not any(s in line for s in ["Recordatorio:", "Acogida,", "Cierre)", "límites", "Sintesis", "?"]):
                sintesis_text.append(line.strip())
        if "límites" in line:
            capture_sintesis = True
    if sintesis_text:
        form_data["sintesis"] = " ".join(sintesis_text)

    return form_data


def extract(pdf_path: str) -> pd.DataFrame:
    """
    Main entry point. Extracts structured data from a single PDF.
    Returns a single-row DataFrame.
    """
    lines, num_pages = _extract_lines(pdf_path)
    form_data = _parse_lines(lines, num_pages)

    for key, value in form_data.items():
        if isinstance(value, str):
            form_data[key] = _normalize(value)

    form_data["filename"] = pdf_path
    return pd.DataFrame([form_data])

if __name__ == "__main__":
    pdf_path = "/tmp/llamatel/58-AJ.pdf"  # Replace with actual PDF path
    df = extract(pdf_path)
    print(df.T)