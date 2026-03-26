import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from playwright.sync_api import sync_playwright, Page
from config.settings import BOT_USERNAME, BOT_PASSWORD, START_DATE, END_DATE, BASE_URL, PDF_TMP_DIR
import os

def scrape(on_record=None, start_date: str = None, end_date: str = None) -> None:

    _start = start_date or START_DATE
    _end = end_date or END_DATE

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            accept_downloads=True,
            viewport={"width": 1280, "height": 720},
            locale="es-ES",
            extra_http_headers={"Accept-Language": "es-ES,es;q=0.9"}
        )
        page = context.new_page()

        def login():
            page.goto(BASE_URL)
            page.wait_for_load_state("domcontentloaded")
            page.fill("input[name='usuario_auth_login']", BOT_USERNAME)
            page.fill("input[name='clave_auth_login']", BOT_PASSWORD)
            page.click("input[value='Entrar']")
            page.wait_for_load_state("networkidle")
            print("Logged in! Current URL:", page.url)

        def search_records() -> int:
            page.click("a[href='?class=llamadas&menu_pos=2']")
            page.wait_for_load_state("networkidle")
            page.fill("input[name='desde']", _start)
            page.fill("input[name='hasta']", _end)
            page.locator("input.botones[value='Buscar >>']").click()
            print("clicked too")
            page.wait_for_selector("td.query_result_paginas font b", state="visible")
            raw_count = page.locator("td.query_result_paginas font b").inner_text()
            total = int(raw_count.strip().replace(",", "").replace(".", ""))
            print(f"Records found: {total}")
            return total

        def download_pdf() -> str | None:
            numero1 = page.locator("input[name='numero1']").input_value()
            numero2 = page.locator("input[name='numero2']").input_value()
            record_name = f"{numero1}-{numero2}"
            os.makedirs(PDF_TMP_DIR, exist_ok=True)
            pdf_path = os.path.join(PDF_TMP_DIR, f"{record_name}.pdf")
            if os.path.exists(pdf_path):
                print(f"Skipping {record_name}, already exists.")
                return None
            page.pdf(
                path=pdf_path,
                format="legal",
                print_background=True,
                landscape=False,
                margin={"top": "1cm", "bottom": "1cm", "left": "1cm", "right": "1cm"}
            )
            print(f"Saved PDF: {pdf_path}")
            return pdf_path

        def go_to_next() -> bool:
            next_link = page.locator("a:has-text('Siguiente')")
            if next_link.count() > 0:
                next_link.click()
                page.wait_for_load_state("networkidle")
                return True
            return False

        # --- main flow ---
        login()
        total = search_records()
        page.locator("tr.queryresult").first.click()
        page.wait_for_load_state("networkidle")

        for i in range(total):
            print(f"Processing record {i + 1}/{total}...")
            pdf_path = download_pdf()
            if pdf_path and on_record:
                try:
                    on_record(pdf_path)
                except Exception as e:
                    print(f"Failed to process {pdf_path}: {e}, continuing...")
            if not go_to_next():
                print(f"Finished at record {i + 1}.")
                break

        browser.close()


if __name__ == "__main__":
    scrape()