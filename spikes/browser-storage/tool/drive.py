"""Drives the spike in one browser: full run, reload/verify, two-tab writes.

Usage: drive.py <browser> <port> [banks] [content]
"""
import asyncio, json, sys
from playwright.async_api import async_playwright

browser_name, port = sys.argv[1], int(sys.argv[2])
banks = sys.argv[3] if len(sys.argv) > 3 else "219"
content = sys.argv[4] if len(sys.argv) > 4 else "0"
base = f"http://127.0.0.1:{port}/"


async def run_page(page, query, timeout=1800):
    done = asyncio.get_running_loop().create_future()

    def on_console(msg):
        t = msg.text
        if t.startswith("SPIKE_RESULT ") and not done.done():
            done.set_result(json.loads(t[len("SPIKE_RESULT "):]))
        elif t.startswith("SPIKE_LOG "):
            print(f"  [{browser_name}] {t[10:]}", file=sys.stderr, flush=True)

    page.on("console", on_console)
    page.on("pageerror", lambda e: print(f"  [{browser_name}] pageerror {e}", file=sys.stderr, flush=True))
    await page.goto(base + query)
    return await asyncio.wait_for(done, timeout)


async def main():
    out = {"browser": browser_name}
    async with async_playwright() as p:
        browser = await getattr(p, browser_name).launch()
        ctx = await browser.new_context()
        page = await ctx.new_page()
        out["full"] = await run_page(page, f"?phase=full&banks={banks}&content={content}")
        await page.close()
        page = await ctx.new_page()
        out["verifyAfterReload"] = await run_page(page, "?phase=verify")
        await page.close()
        a, b = await ctx.new_page(), await ctx.new_page()
        out["twoTabs"] = await asyncio.gather(
            run_page(a, "?phase=tabwrite"), run_page(b, "?phase=tabwrite"))
        await browser.close()
    print(json.dumps(out, ensure_ascii=False, indent=1))

asyncio.run(main())
