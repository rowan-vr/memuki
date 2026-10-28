"""Like drive.py, but samples total PSS of the Playwright browser's processes.

Reports baseline (blank page), peak and settled memory for the full run, and
peak and settled memory when a fresh page opens the existing databases.

Usage: drive_mem.py <browser> <port> <content 0|1>
"""
import asyncio, glob, json, sys, threading, time
from playwright.async_api import async_playwright

browser_name, port, content = sys.argv[1], int(sys.argv[2]), sys.argv[3]
base = f"http://127.0.0.1:{port}/"


def pss_mb():
    """Total PSS of this process's descendants (the Playwright driver and its browser)."""
    import os
    children = {}
    for d in glob.glob("/proc/[0-9]*"):
        try:
            ppid = int(open(f"{d}/stat").read().rsplit(")", 1)[1].split()[1])
            children.setdefault(ppid, []).append(int(d[6:]))
        except (OSError, ValueError, IndexError):
            pass
    todo, total = list(children.get(os.getpid(), [])), 0
    while todo:
        pid = todo.pop()
        todo.extend(children.get(pid, []))
        try:
            for line in open(f"/proc/{pid}/smaps_rollup"):
                if line.startswith("Pss:"):
                    total += int(line.split()[1])
        except OSError:
            pass
    return total / 1024


class Sampler:
    def __init__(self):
        self.peak = 0.0
        self.stop = False
        threading.Thread(target=self.loop, daemon=True).start()

    def loop(self):
        while not self.stop:
            self.peak = max(self.peak, pss_mb())
            time.sleep(0.5)

    def reset(self):
        self.peak = pss_mb()


async def run_page(page, query, timeout=3600):
    done = asyncio.get_running_loop().create_future()

    def on_console(msg):
        t = msg.text
        if t.startswith("SPIKE_RESULT ") and not done.done():
            done.set_result(json.loads(t[len("SPIKE_RESULT "):]))
        elif t.startswith("SPIKE_LOG "):
            print(f"  [{browser_name}:{port}:{content}] {t[10:]}", file=sys.stderr, flush=True)

    page.on("console", on_console)
    await page.goto(base + query)
    return await asyncio.wait_for(done, timeout)


async def settled():
    await asyncio.sleep(5)
    return round(pss_mb())


async def main():
    out = {"browser": browser_name, "port": port, "content": content}
    sampler = Sampler()
    async with async_playwright() as p:
        browser = await getattr(p, browser_name).launch()
        ctx = await browser.new_context()
        page = await ctx.new_page()
        await page.goto("about:blank")
        out["baselineMb"] = await settled()
        sampler.reset()
        full = await run_page(page, f"?phase=full&content={content}")
        out["fullPeakMb"] = round(sampler.peak)
        out["fullSettledMb"] = await settled()
        out["error"] = full.get("error")
        out["implementation"] = full["opened"]["dict"]["implementation"]
        out["dict"] = full.get("dict")
        out["dictBytes"] = full.get("dictBytes")
        out["usage"] = full["storage"]["usage"]
        await page.close()
        await asyncio.sleep(3)
        out["afterCloseMb"] = round(pss_mb())
        page = await ctx.new_page()
        sampler.reset()
        verify = await run_page(page, "?phase=verify")
        out["reopenPeakMb"] = round(sampler.peak)
        out["reopenSettledMb"] = await settled()
        out["verify"] = verify.get("counts") or verify.get("error")
        await browser.close()
    sampler.stop = True
    print(json.dumps(out, ensure_ascii=False))

asyncio.run(main())
