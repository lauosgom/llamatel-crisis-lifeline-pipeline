from playwright.sync_api import sync_playwright
from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env file

USERNAME = os.getenv("BOT_USERNAME")
PASSWORD = os.getenv("BOT_PASSWORD")

if USERNAME is None or PASSWORD is None:
    missing = []
    if USERNAME is None:
        missing.append("BOT_USERNAME")
    if PASSWORD is None:
        missing.append("BOT_PASSWORD")
    raise RuntimeError(
        f"Required environment variable(s) {', '.join(missing)} are not set. "
        "Please define them (e.g., in your environment or .env file) before running this script."
    )
START_DATE = "01/01/2025"  # or make these parameters too DD/MM/YYYY
END_DATE   = "31/12/2025"

print("Starting bot with username:", USERNAME)
print("Target date range:", START_DATE, "to", END_DATE)


with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)  # Set True once it's working
    context = browser.new_context(accept_downloads=True)
    page = context.new_page()

    # --- LOGIN ---
    page.goto("https://llamatel.telefonodelaesperanza.org/index.php")
    page.wait_for_load_state("domcontentloaded")

    page.fill("input[name='usuario_auth_login']", USERNAME)
    page.fill("input[name='clave_auth_login']", PASSWORD)
    page.click("input[value='Entrar']")
    page.wait_for_load_state("networkidle")

    print("Logged in! Current URL:", page.url)

    # --- NEXT STEPS (fill fields, download PDFs) ---
    # --- NAVIGATE TO GESTIÓN ---
    page.click("a[href='?class=llamadas&menu_pos=2']")
    page.wait_for_load_state("networkidle")
    print("Navigated to Gestión, URL:", page.url)
    
    # --- FILL DATE RANGE ---
    page.fill("input[name='desde']", START_DATE)
    page.fill("input[name='hasta']", END_DATE)

    # --- SUBMIT SEARCH ---
    page.click("input[value='To look for >>']")
    page.wait_for_load_state("networkidle")
    print("Search submitted! URL:", page.url)

    # --- GET RECORD COUNT ---
    raw_count = page.locator("td.query_result_paginas b").inner_text()
    count_text = raw_count.strip().replace(",", "").replace(".", "")
    print(f"Records found: {count_text}")
    total = int(count_text)

    # --- CLICK FIRST RESULT ---
    page.locator("tr.queryresult").first.click()
    page.wait_for_load_state("networkidle")

    for i in range(2):
        print(f"Processing record {i + 1}/{total}...")

        # Get filename from numero1 and numero2 fields
        numero1 = page.locator("input[name='numero1']").input_value()
        numero2 = page.locator("input[name='numero2']").input_value()
        record_name = f"{numero1}-{numero2}"

        # Export page as PDF
        pdf_path = f"/tmp/{record_name}.pdf"
        page.pdf(
            path=pdf_path,
            format="legal",
            print_background=True,
            landscape=False,
            margin={"top": "1cm", "bottom": "1cm", "left": "1cm", "right": "1cm"}
        )
        print(f"Saved PDF: {pdf_path}")

        # Upload to GCS
        # upload_to_gcs(GCS_BUCKET, pdf_path, f"llamatel/{record_name}.pdf")
        # os.remove(pdf_path)

        # Click "Siguiente >>" to go to next record
        next_link = page.locator("a:has-text('Siguiente')")
        if next_link.count() > 0:
            next_link.click()
            page.wait_for_load_state("networkidle")
        else:
            print(f"Finished at record {i + 1}.")
            break
    

    input("Press Enter to close browser...")  # keeps browser open to inspect
    browser.close()
