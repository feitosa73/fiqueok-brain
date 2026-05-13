import os
import time
from playwright.sync_api import sync_playwright

def batch_export():
    # Caminho de destino baseado no seu diretório atual
    output_dir = r"C:\Users\fiqueok\Perplexity_IA\export_data"
    input_file = "threads.md"
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with sync_playwright() as p:
        print("🚀 Iniciando motor Playwright (Modo Visível para Bypass WAF)...")
        browser = p.chromium.launch(headed=True)
        context = browser.new_context()
        page = context.new_page()

        # Carregar links únicos
        if not os.path.exists(input_file):
            print(f"❌ Erro: Arquivo {input_file} não encontrado!")
            return

        with open(input_file, "r", encoding="utf-8") as f:
            urls = list(set([line.strip() for line in f if "perplexity.ai/search/" in line]))

        print(f"✅ Total de {len(urls)} threads únicas mapeadas.")
        print("\n--- AÇÃO REQUERIDA ---")
        print("1. A janela do navegador vai abrir.")
        print("2. Faça o LOGIN no Perplexity se necessário.")
        print("3. Quando visualizar sua Library, volte aqui e pressione ENTER.")
        
        page.goto("https://www.perplexity.ai/library")
        input("Pressione ENTER para começar o download...") 

        for i, url in enumerate(urls):
            try:
                print(f"[{i+1}/{len(urls)}] Extraindo: {url}")
                page.goto(url, wait_until="networkidle")
                time.sleep(3) # Delay estratégico para evitar bloqueio
                
                # Captura título e conteúdo puro
                title_raw = page.title().split("-")[0].strip()
                # Sanitização de nome de arquivo para Windows
                title = "".join([c for c in title_raw if c.isalnum() or c in (' ', '-', '_')]).rstrip()
                if not title: title = f"thread_{i}"
                
                content = page.locator("body").inner_text()
                file_path = os.path.join(output_dir, f"{title}.md")
                
                with open(file_path, "w", encoding="utf-8") as md:
                    md.write(f"---\noriginal_url: {url}\nexported_at: {time.ctime()}\nproject: PRJ018\n---\n\n# {title}\n\n{content}")
                
                print(f"  OK: {title}.md")
            except Exception as e:
                print(f"  ❌ Erro em {url}: {e}")

        print(f"\n🏆 Finalizado! Arquivos salvos em: {output_dir}")
        browser.close()

if __name__ == "__main__":
    batch_export()
