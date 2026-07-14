// Configuration
const CONFIG = {
    overheadCompensationFactor: 1.06, // Network overhead compensation
    downloadDuration: 15, // Increased slightly for better accuracy
    uploadDuration: 10,
    endpoints: {
        dl: 'backend/garbage',
        ul: 'backend/empty',
        ping: 'backend/empty',
        ip: 'backend/getIP',
        telemetry: 'backend/results/telemetry'
    }
};

// State
let isRunning = false;
let currentIspInfo = null; // holds full ISP info from getIP for telemetry

/** @type {SVGCircleElement} */
const circle = document.getElementById('circle');
const radius = circle.r.baseVal.value;
const circumference = radius * 2 * Math.PI;

// UI References
const els = {
    startBtn: document.getElementById('start-btn'),
    speed: document.getElementById('current-speed'),
    speedUnit: document.querySelector('.speed-unit'),
    status: document.getElementById('status-text'),
    ip: document.getElementById('ip-info'),
    ping: document.getElementById('ping-value'),
    jitter: document.getElementById('jitter-value'),
    dl: document.getElementById('dl-value'),
    ul: document.getElementById('ul-value'),
    ring: document.querySelector('.progress-ring'),
    shareArea: document.getElementById('share-area'),
    shareUrl: document.getElementById('share-url'),
    shareImage: document.getElementById('share-image'),
    shareToast: document.getElementById('share-toast')
};

let shareToastTimer = null;

function showShareToast() {
    if (!els.shareToast) return;
    els.shareToast.classList.add('visible');
    if (shareToastTimer) clearTimeout(shareToastTimer);
    shareToastTimer = setTimeout(() => {
        els.shareToast.classList.remove('visible');
    }, 1500);
}

// Initialize Gauge
circle.style.strokeDasharray = `${circumference} ${circumference}`;
circle.style.strokeDashoffset = circumference;

function setProgress(percent) {
    const clampedPercent = Math.max(0, Math.min(percent, 100));
    const offset = circumference - (clampedPercent / 100) * circumference;
    circle.style.strokeDashoffset = offset;
}

function createSpeedDisplay(startTime, getLoadedBytes) {
    let frameId = null;

    const render = () => {
        frameId = null;
        const duration = (performance.now() - startTime) / 1000;
        if (duration <= 0.1) return;

        const speed = (getLoadedBytes() * 8 * CONFIG.overheadCompensationFactor) / duration / 1_000_000;
        els.speed.textContent = speed.toFixed(1);
        setProgress(speed);
    };

    return {
        update() {
            if (frameId === null) frameId = requestAnimationFrame(render);
        },
        flush() {
            if (frameId !== null) cancelAnimationFrame(frameId);
            render();
        }
    };
}

// Utils
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

/**
 * @typedef {Object} IpInfo
 * @property {string} processedString - Processed IP address or ISP string
 * @property {Object} rawIspInfo - Raw ISP information from geolocation service
 * @property {string} rawIspInfo.city - City name
 * @property {string} rawIspInfo.country - Country code/name
 * @property {string} rawIspInfo.hostname - Hostname
 * @property {string} rawIspInfo.ip - IP address
 * @property {string} rawIspInfo.loc - Geographic coordinates
 * @property {string} rawIspInfo.org - Organization/ISP name
 * @property {string} rawIspInfo.postal - Postal code
 * @property {?string} rawIspInfo.readme - Readme information
 * @property {string} rawIspInfo.region - Region/state
 * @property {string} rawIspInfo.timezone - Timezone */

async function getIP() {
    try {
        // Add random param to prevent caching
        const res = await fetch(`${CONFIG.endpoints.ip}?isp=true&r=${Math.random()}`);
        if (!res.ok) throw new Error('IP Fetch Failed');
        /** @type {IpInfo} */
        const data = await res.json();
        currentIspInfo = data;
        // Handle different LibreSpeed backend versions
        const isp = data.processedString || data.isp || "Unknown ISP";
        els.ip.textContent = isp;
    } catch (e) {
        console.error(e);
        els.ip.textContent = "Unknown ISP";
    }
}

// Telemetry: send results to backend and return test ID
async function sendTelemetry() {
    try {
        const ispinfo = {
            processedString: (currentIspInfo && currentIspInfo.processedString) ? currentIspInfo.processedString : els.ip.textContent,
            ...(currentIspInfo && currentIspInfo.rawIspInfo ? { rawIspInfo: currentIspInfo.rawIspInfo } : {})
        };
        const fd = new FormData();
        fd.append('ispinfo', JSON.stringify(ispinfo));
        fd.append('dl', els.dl.textContent);
        fd.append('ul', els.ul.textContent);
        fd.append('ping', els.ping.textContent);
        fd.append('jitter', els.jitter.textContent);
        fd.append('log', '');
        fd.append('extra', '');

        const res = await fetch(`${CONFIG.endpoints.telemetry}?r=${Math.random()}`, {
            method: 'POST',
            body: fd
        });
        const txt = await res.text();
        const m = txt.match(/^id\s+(\S+)/);
        return m ? m[1] : null;
    } catch (e) {
        console.error('Telemetry failed', e);
        return null;
    }
}

async function runPing() {
    els.status.textContent = "Pinging...";
    const pings = [];
    
    // Warmup
    try { await fetch(`${CONFIG.endpoints.ping}?r=${Math.random()}`); } catch(e){}

    for (let i = 0; i < 6; i++) {
        const start = performance.now();
        try {
            await fetch(`${CONFIG.endpoints.ping}?r=${Math.random()}`);
            const end = performance.now();
            pings.push(end - start);
        } catch(e) {
            pings.push(100); // Penalty for fail
        }
        await sleep(50);
    }
    
    // Calculate Stats (remove min/max outliers)
    pings.sort((a, b) => a - b);
    const validPings = pings.length > 2 ? pings.slice(1, -1) : pings;
    const avgPing = validPings.reduce((a, b) => a + b, 0) / validPings.length;
    
    // Jitter: standard deviation
    const variance = validPings.reduce((acc, val) => acc + Math.pow(val - avgPing, 2), 0) / validPings.length;
    const jitter = Math.sqrt(variance);

    els.ping.textContent = avgPing.toFixed(1);
    els.jitter.textContent = jitter.toFixed(1);
}

async function runDownload() {
    els.status.textContent = "Downloading...";
    circle.style.stroke = 'var(--accent-dl)';
    
    const startT = performance.now();
    let loadedBytes = 0;
    let keepGoing = true;
    const controllers = new Set();
    const display = createSpeedDisplay(startT, () => loadedBytes);
    const stopTimer = setTimeout(() => {
        keepGoing = false;
        controllers.forEach((controller) => controller.abort());
    }, CONFIG.downloadDuration * 1000);

    // We use a concurrent stream approach
    const concurrency = 2; // 2 parallel streams is usually enough for modern browsers
    const workers = [];

    const downloadWorker = async () => {
        while (keepGoing) {
            const controller = new AbortController();
            controllers.add(controller);
            try {
                // Request a large chunk (100MB) to sustain the stream
                const response = await fetch(`${CONFIG.endpoints.dl}?ckSize=100&r=${Math.random()}`, {
                    signal: controller.signal,
                    cache: 'no-store'
                });
                if (!response.ok || !response.body) throw new Error('Download request failed');
                const reader = response.body.getReader();

                while (true) {
                    if (!keepGoing) {
                        await reader.cancel();
                        break;
                    }
                    
                    const { done, value } = await reader.read();
                    
                    if (done) break;
                    
                    // value.length contains the size of the packet received
                    loadedBytes += value.length;
                    display.update();
                }
            } catch (e) {
                if (keepGoing && e.name !== 'AbortError') {
                    console.error("Download stream failed", e);
                    await sleep(100); // Wait a bit before retrying
                }
            } finally {
                controllers.delete(controller);
            }
        }
    };

    for(let i=0; i<concurrency; i++) workers.push(downloadWorker());
    await Promise.all(workers);
    clearTimeout(stopTimer);
    display.flush();

    // Final Calculation
    const totalTime = (performance.now() - startT) / 1000;
    const finalSpeed = ((loadedBytes * 8 * CONFIG.overheadCompensationFactor) / totalTime) / 1000000;
    els.dl.textContent = finalSpeed.toFixed(1);
}

async function runUpload() {
    els.status.textContent = "Uploading...";
    circle.style.stroke = 'var(--accent-ul)';
    
    const startT = performance.now();
    let loadedBytes = 0;
    let keepGoing = true;
    const activeXhrs = new Set();

    const stopTimer = setTimeout(() => {
        keepGoing = false;
        activeXhrs.forEach((xhr) => xhr.abort());
    }, CONFIG.uploadDuration * 1000);

    // Generate a 2MB blob of data to upload
    const data = new Blob([new Uint8Array(2 * 1024 * 1024).fill(97)]);
    const concurrency = 4;
    const workers = [];
    const display = createSpeedDisplay(startT, () => loadedBytes);

    const singleUpload = () => new Promise((resolve) => {
        const xhr = new XMLHttpRequest();
        activeXhrs.add(xhr);
        let lastLoaded = 0;

        xhr.open('POST', `${CONFIG.endpoints.ul}?r=${Math.random()}`, true);

        xhr.upload.onprogress = (evt) => {
            // Count only delta since last progress to avoid double counting
            const delta = (evt.loaded || 0) - lastLoaded;
            lastLoaded = evt.loaded || lastLoaded;
            loadedBytes += Math.max(delta, 0);
            display.update();
            if (!keepGoing && xhr.readyState !== XMLHttpRequest.DONE) {
                xhr.abort();
            }
        };

        xhr.onloadend = () => {
            // Count the final bytes only for a successful completed request.
            if (xhr.status >= 200 && xhr.status < 300 && lastLoaded < data.size) {
                loadedBytes += (data.size - lastLoaded);
                display.update();
            }
            activeXhrs.delete(xhr);
            resolve();
        };

        xhr.send(data);
    });

    const uploadWorker = async () => {
        while (keepGoing) {
            try {
                await singleUpload();
            } catch (e) {
                console.error('Upload failed', e);
                await sleep(100);
                break;
            }
        }
    };

    for (let i = 0; i < concurrency; i++) workers.push(uploadWorker());
    await Promise.all(workers);

    // Abort any lingering XHRs if timer stopped the loop mid-request
    activeXhrs.forEach((xhr) => xhr.abort());
    clearTimeout(stopTimer);
    display.flush();

    const totalTime = (performance.now() - startT) / 1000;
    const finalSpeed = totalTime > 0 ? ((loadedBytes * 8 * CONFIG.overheadCompensationFactor) / totalTime) / 1000000 : 0;
    els.ul.textContent = finalSpeed.toFixed(1);
}

// Main Flow
els.startBtn.addEventListener('click', async () => {
    if (isRunning) return;
    isRunning = true;
    els.startBtn.disabled = true;
    
    // Reset UI
    els.dl.textContent = '--';
    els.ul.textContent = '--';
    els.ping.textContent = '--';
    els.jitter.textContent = '--';
    els.speed.textContent = '0.0';
    if (els.speedUnit) els.speedUnit.style.display = 'block';
    els.shareArea.style.display = 'none';
    setProgress(0);

    try {
        await runPing();
        await runDownload();
        await runUpload();

        // Send telemetry and show share link if testId is returned
        const testId = await sendTelemetry();
        if (testId) {
            // Construct share URL like upstream (base path + /backend/results/?id=TESTID)
            const base = window.location.href.substring(0, window.location.href.lastIndexOf('/'));
            const shareURL = `${base}/backend/results/?id=${testId}`;
            els.shareUrl.value = shareURL;
            els.shareImage.src = shareURL;
            els.shareArea.style.display = '';
            els.status.textContent = "Results ready to share";
        } else {
            els.status.textContent = "Finished";
        }
        els.speed.textContent = "Done";
        setProgress(100);
    } catch (e) {
        console.error('Speed test failed', e);
        els.status.textContent = 'Test failed';
    } finally {
        if (els.speedUnit) els.speedUnit.style.display = 'none';
        els.startBtn.disabled = false;
        els.startBtn.textContent = "Test Again";
        isRunning = false;
    }
});

// Init
getIP();

// Click-to-copy for share URL input (no alert; uses toast)
(() => {
    const input = els.shareUrl;
    if (!input) return;
    input.addEventListener('click', async () => {
        try {
            input.focus();
            input.select();
            const value = input.value || '';
            if (navigator.clipboard && navigator.clipboard.writeText) {
                await navigator.clipboard.writeText(value);
            } else {
                try { document.execCommand('copy'); } catch (e) {}
            }
            showShareToast();
        } catch (e) {
            console.error('Copy failed', e);
        }
    });
})();
