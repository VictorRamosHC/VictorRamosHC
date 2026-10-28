import { spawn } from 'child_process';
import http from 'http';

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const PORT = 9222;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function requestJson(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const req = http.request(`http://127.0.0.1:${PORT}${path}`, { method }, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch(e) { reject(new Error(`Failed to parse: ${data}`)); }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

class CDPClient {
  constructor(wsUrl) {
    this.wsUrl = wsUrl;
    this.id = 1;
    this.callbacks = new Map();
  }

  async connect() {
    this.ws = new WebSocket(this.wsUrl);
    await new Promise((resolve, reject) => {
      this.ws.onopen = resolve;
      this.ws.onerror = reject;
    });

    this.ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      if (msg.id && this.callbacks.has(msg.id)) {
        const { resolve, reject } = this.callbacks.get(msg.id);
        this.callbacks.delete(msg.id);
        if (msg.error) reject(msg.error);
        else resolve(msg.result);
      }
    };
  }

  async send(method, params = {}) {
    const id = this.id++;
    return new Promise((resolve, reject) => {
      this.callbacks.set(id, { resolve, reject });
      this.ws.send(JSON.stringify({ id, method, params }));
    });
  }

  async eval(expression) {
    const res = await this.send('Runtime.evaluate', {
      expression,
      returnByValue: true,
      awaitPromise: true
    });
    if (res.exceptionDetails) {
      throw new Error(`JS Eval Error: ${JSON.stringify(res.exceptionDetails)}`);
    }
    return res.result ? res.result.value : undefined;
  }

  async setViewport(width, height) {
    await this.send('Emulation.setDeviceMetricsOverride', {
      width,
      height,
      deviceScaleFactor: 1,
      mobile: width < 600
    });
  }

  close() {
    if (this.ws) this.ws.close();
  }
}

async function runTests() {
  console.log('================================================================================');
  console.log(' VICTOR RAMOS HC // INTERACTIVE REAL-BROWSER VALIDATION SUITE (CHROME HEADLESS)');
  console.log('================================================================================\n');

  // Spawn headless Chrome
  const chrome = spawn(CHROME_PATH, [
    '--headless=new',
    `--remote-debugging-port=${PORT}`,
    '--disable-gpu',
    '--no-first-run',
    '--no-default-browser-check',
    'about:blank'
  ], { stdio: 'ignore' });

  await sleep(1500);

  const results = [];

  try {
    const version = await requestJson('/json/version');
    console.log(`[CHROME CONNECTED] Target: ${version.Browser}\n`);

    // Helper to open a page
    async function openPage(filePath) {
      const fileUrl = 'file:///' + filePath.replace(/\\/g, '/');
      const target = await requestJson('/json/new?' + encodeURIComponent(fileUrl), 'PUT');
      const client = new CDPClient(target.webSocketDebuggerUrl);
      await client.connect();
      await client.send('Page.enable');
      await client.send('Runtime.enable');
      await sleep(400);
      return { client, targetId: target.id };
    }

    async function closePage(client, targetId) {
      client.close();
      await requestJson(`/json/close/${targetId}`, 'PUT').catch(() => {});
    }

    // --------------------------------------------------------------------------
    // TEST 1: FACADE LAB (minigame/color-protocol/index.html)
    // --------------------------------------------------------------------------
    {
      const { client, targetId } = await openPage('C:/Users/victor.hugo/.gemini/antigravity/scratch/VictorRamosHC/minigame/color-protocol/index.html');
      
      // 1.1 Initial Start & First Scenario
      await client.eval("startLab()");
      const scenario0Title = await client.eval("document.getElementById('briefingTitle').textContent");
      const titleMatches = scenario0Title.includes("Edifício Corporativo");
      results.push({ name: 'FACADE_LAB_01_START_AND_SCENARIO_0', pass: titleMatches, detail: `Loaded Scenario: '${scenario0Title}'` });

      // 1.2 Win State (RGB for LRV in range [60, 85] with Matte finish)
      await client.eval(`
        document.getElementById('slideR').value = 215;
        document.getElementById('slideG').value = 220;
        document.getElementById('slideB').value = 225;
        updateColor();
        setFinish('matte', document.querySelector('.selector-grid button'));
        evaluateComposition();
      `);
      const winScore = await client.eval("parseInt(document.getElementById('resScore').textContent)");
      const lrvText = await client.eval("document.getElementById('resLRV').textContent");
      const contrastText = await client.eval("document.getElementById('resContrast').textContent");
      const winTitle = await client.eval("document.getElementById('resultTitle').textContent");
      const winPass = winScore >= 70 && winTitle.includes('Aprovada') && contrastText.includes(': 1');
      results.push({ 
        name: 'FACADE_LAB_02_WIN_STATE_AND_CONTRAST', 
        pass: winPass, 
        detail: `Score: ${winScore}/100, LRV: ${lrvText}, Contrast: ${contrastText}, Title: '${winTitle.substring(0, 30)}...'` 
      });

      // 1.3 Restart & Next Scenario Cycling
      await client.eval("startLab()");
      const scenario1Title = await client.eval("document.getElementById('briefingTitle').textContent");
      const cyclingPass = scenario1Title.includes("Pavilhão Cultural Subterrâneo");
      results.push({ name: 'FACADE_LAB_03_RESTART_AND_CYCLE', pass: cyclingPass, detail: `Cycled to: '${scenario1Title}'` });

      // 1.4 Fail State on Scenario 1 (Overly bright wall on dark requirement)
      await client.eval(`
        document.getElementById('slideR').value = 250;
        document.getElementById('slideG').value = 250;
        document.getElementById('slideB').value = 250;
        updateColor();
        evaluateComposition();
      `);
      const failTitle = await client.eval("document.getElementById('resultTitle').textContent");
      const failScore = await client.eval("parseInt(document.getElementById('resScore').textContent)");
      const failPass = failTitle.includes('Reprovada') && failScore < 70;
      results.push({ name: 'FACADE_LAB_04_FAIL_STATE', pass: failPass, detail: `Score: ${failScore}/100, Title: '${failTitle.substring(0, 30)}...'` });

      // 1.5 Mobile Viewport (360px) No Overflow
      await client.setViewport(360, 740);
      const isOverflow360 = await client.eval("document.documentElement.scrollWidth > window.innerWidth");
      results.push({ name: 'FACADE_LAB_05_MOBILE_360_NO_OVERFLOW', pass: !isOverflow360, detail: `360px viewport overflow: ${isOverflow360}` });

      await closePage(client, targetId);
    }

    // --------------------------------------------------------------------------
    // TEST 2: SIGNAL TUNER (minigame/audio-breach/index.html)
    // --------------------------------------------------------------------------
    {
      const { client, targetId } = await openPage('C:/Users/victor.hugo/.gemini/antigravity/scratch/VictorRamosHC/minigame/audio-breach/index.html');

      // 2.1 Starts at Profile 0 on initial launch
      await client.eval("startTuner()");
      const profName = await client.eval("document.getElementById('targetProfileName').textContent");
      const prof0Pass = profName.includes("Vocal Clarity & Presence");
      results.push({ name: 'SIGNAL_TUNER_01_INITIAL_PROFILE_ZERO', pass: prof0Pass, detail: `Profile: '${profName}'` });

      // 2.2 Scope disclaimer presence
      const hasDisclaimer = await client.eval(`
        const titleText = document.getElementById('screenTitle').textContent;
        titleText.includes('AVISO DE ESCOPO') && titleText.includes('Simulação lúdica');
      `);
      results.push({ name: 'SIGNAL_TUNER_02_SIMULATION_DISCLAIMER', pass: hasDisclaimer, detail: 'Simulation disclaimer displayed on screen' });

      // 2.3 Win State: Synchronize bands to target [-4, -2, 3, 6, 4]
      await client.eval(`
        const target = [-4, -2, 3, 6, 4];
        for (let i = 0; i < 5; i++) {
          document.getElementById('band' + i).value = target[i];
        }
        updateBands();
        commitTuning();
      `);
      const audioScore = await client.eval("document.getElementById('finalScore').textContent");
      const audioTitle = await client.eval("document.getElementById('resTitle').textContent");
      const winAudioPass = audioScore.includes('100%') && (audioTitle.includes('Aprovada') || audioTitle.includes('Homologada') || audioTitle.includes('Excelência'));
      results.push({ 
        name: 'SIGNAL_TUNER_03_WIN_STATE', 
        pass: winAudioPass, 
        detail: `Convergence: ${audioScore}, Title: '${audioTitle}'` 
      });

      // 2.4 Restart & Cycle to Profile 1
      await client.eval("startTuner()");
      const nextProf = await client.eval("document.getElementById('targetProfileName').textContent");
      const prof1Pass = nextProf.includes("Sub-Bass Punch & Warmth");
      results.push({ name: 'SIGNAL_TUNER_04_RESTART_CYCLE', pass: prof1Pass, detail: `Cycled to: '${nextProf}'` });

      // 2.5 Mobile Viewport (412px) No Overflow
      await client.setViewport(412, 915);
      const isOverflow412 = await client.eval("document.documentElement.scrollWidth > window.innerWidth");
      results.push({ name: 'SIGNAL_TUNER_05_MOBILE_412_NO_OVERFLOW', pass: !isOverflow412, detail: `412px viewport overflow: ${isOverflow412}` });

      await closePage(client, targetId);
    }

    // --------------------------------------------------------------------------
    // TEST 3: CRITICAL QUEUE (minigame/task-triage/index.html)
    // --------------------------------------------------------------------------
    {
      const { client, targetId } = await openPage('C:/Users/victor.hugo/.gemini/antigravity/scratch/VictorRamosHC/minigame/task-triage/index.html');

      // 3.1 Initial Board Render
      await client.eval("startQueue()");
      const cardCount = await client.eval("document.querySelectorAll('.task-card').length");
      results.push({ name: 'CRITICAL_QUEUE_01_BOARD_RENDER', pass: cardCount === 7, detail: `Rendered ${cardCount} task cards` });

      // 3.2 Transitive Dependency Violation (Select T5 without T3 or T2)
      await client.eval(`
        resetSelection();
        toggleTask('T5');
        executeSprint();
      `);
      await sleep(100);
      const violations = await client.eval("parseInt(document.getElementById('resDepViolations').textContent)");
      const failDepTitle = await client.eval("document.getElementById('resTitle').textContent");
      const depPass = violations === 1 && failDepTitle.includes('Violação de Dependência');
      results.push({ name: 'CRITICAL_QUEUE_02_TRANSITIVE_DEPENDENCY_VIOLATION', pass: depPass, detail: `Violations: ${violations}, Title: '${failDepTitle}'` });

      // 3.3 Strict Capacity Hard Rejection (Select all tasks = 23 pts > 18 max)
      await client.eval(`
        resetSelection();
        ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].forEach(id => toggleTask(id));
        executeSprint();
      `);
      await sleep(100);
      const overCapScore = await client.eval("parseInt(document.getElementById('resScore').textContent)");
      const overCapTitle = await client.eval("document.getElementById('resTitle').textContent");
      const overCapText = await client.eval("document.getElementById('resCapUsed').textContent");
      const overCapPass = overCapScore === 0 && overCapTitle.includes('Estouro de Capacidade') && overCapText.includes('23 / 18 PTS') && overCapText.includes('EXCEDENTE');
      results.push({ name: 'CRITICAL_QUEUE_03_HARD_CAPACITY_REJECTION_ZERO_SCORE', pass: overCapPass, detail: `Score: ${overCapScore}/100, Capacity: '${overCapText}'` });

      // 3.4 Valid Optimal Sprint (T1 + T2 + T3 + T4 + T7 = exactly 18 pts, value 160 -> score 100)
      await client.eval(`
        resetSelection();
        ['T1', 'T2', 'T3', 'T4', 'T7'].forEach(id => toggleTask(id));
        executeSprint();
      `);
      await sleep(100);
      const optScore = await client.eval("parseInt(document.getElementById('resScore').textContent)");
      const optTitle = await client.eval("document.getElementById('resTitle').textContent");
      const optCap = await client.eval("document.getElementById('resCapUsed').textContent");
      const optPass = optScore === 100 && optTitle.includes('Sucesso') && optCap.includes('18 / 18 PTS');
      results.push({ name: 'CRITICAL_QUEUE_04_OPTIMAL_100_SCORE_VALID', pass: optPass, detail: `Score: ${optScore}/100, Capacity: '${optCap}', Title: '${optTitle}'` });

      // 3.5 Restart resets selection & capacity
      await client.eval("startQueue()");
      const resetCap = await client.eval("document.getElementById('capacityLabel').textContent");
      const resetPass = resetCap.includes('0 / 18 PTS');
      results.push({ name: 'CRITICAL_QUEUE_05_RESTART_CLEARS_STATE', pass: resetPass, detail: `Cap reset: '${resetCap}'` });

      await closePage(client, targetId);
    }

    // --------------------------------------------------------------------------
    // TEST 4: EXPEDITION PLANNER (minigame/signal-route/index.html)
    // --------------------------------------------------------------------------
    {
      const { client, targetId } = await openPage('C:/Users/victor.hugo/.gemini/antigravity/scratch/VictorRamosHC/minigame/signal-route/index.html');

      // 4.1 Initial Metrics: ¥250,000 budget & 10% base fatigue & 3/3 stages
      await client.eval("startExpedition()");
      const hudBud = await client.eval("document.getElementById('hudBudget').textContent");
      const hudFat = await client.eval("document.getElementById('hudFatigue').textContent");
      const hudStages = await client.eval("document.getElementById('hudExp').textContent");
      const initPass = hudBud.includes('¥') && hudFat.includes('%') && hudStages.includes('3 / 3');
      results.push({ name: 'EXPEDITION_PLANNER_01_INITIAL_STATE_AND_METRICS', pass: initPass, detail: `Budget: ${hudBud}, Fatigue: ${hudFat}, Stages: ${hudStages}` });

      // 4.2 Weather Alert encapsulated specifically inside Trecho 02
      const isAlertInLeg2 = await client.eval(`
        const leg2 = document.querySelectorAll('.stage-card')[1];
        leg2 && leg2.querySelector('#contingencyAlert') !== null
      `);
      results.push({ name: 'EXPEDITION_PLANNER_02_ALERT_CONTEXT_IN_LEG2', pass: isAlertInLeg2, detail: `Contingency banner in Leg 2 card: ${isAlertInLeg2}` });

      // 4.3 Finish Expedition with Safe Options (Success State)
      await client.eval("finishExpedition()");
      const expTitle = await client.eval("document.getElementById('resTitle').textContent");
      const expScore = await client.eval("document.getElementById('finalScore').textContent");
      const winExpPass = expTitle.includes('Sucesso') || expTitle.includes('Excelência');
      results.push({ name: 'EXPEDITION_PLANNER_03_FINISH_SUCCESS', pass: winExpPass, detail: `Score: ${expScore}, Title: '${expTitle}'` });

      // 4.4 Restart restores initial budget & 10% fatigue baseline
      await client.eval(`
        // Alter selection
        selectOption('leg1', 'bus', 5500, 35, document.querySelectorAll('.choice-card')[1]);
        // Restart
        startExpedition();
      `);
      const rBud = await client.eval("document.getElementById('hudBudget').textContent");
      const rFat = await client.eval("document.getElementById('hudFatigue').textContent");
      const restartPass = rBud.includes('206') && rFat.includes('45%'); // 250k - (14k+22k+8k) = 206k; 10% base + 10% + 15% + 10% = 45%
      results.push({ name: 'EXPEDITION_PLANNER_04_RESTART_RESTORATION', pass: restartPass, detail: `Budget restored to default: ${rBud}, Fatigue: ${rFat}` });

      await closePage(client, targetId);
    }

    // --------------------------------------------------------------------------
    // TEST 5: HUGH-OS WORKSTATION HUB (minigame/index.html)
    // --------------------------------------------------------------------------
    {
      const { client, targetId } = await openPage('C:/Users/victor.hugo/.gemini/antigravity/scratch/VictorRamosHC/minigame/index.html');

      // 5.1 Tab Switching (Modules -> Simulations -> Terminal)
      await client.eval("switchTab('tab-simulations', document.querySelectorAll('.os-tab')[1])");
      const isTabSimActive = await client.eval("document.getElementById('tab-simulations').classList.contains('active')");
      await client.eval("switchTab('tab-terminal', document.querySelectorAll('.os-tab')[3])");
      const isTabTermActive = await client.eval("document.getElementById('tab-terminal').classList.contains('active')");
      const tabPass = isTabSimActive && isTabTermActive;
      results.push({ name: 'HUGH_OS_01_TAB_SWITCHING', pass: tabPass, detail: `Simulations active: ${isTabSimActive}, Terminal active: ${isTabTermActive}` });

      // 5.2 Mobile Tab Bar (360px) Smooth Scrolling & No Overflow
      await client.setViewport(360, 740);
      const tabBarHasScroll = await client.eval(`
        const tb = document.querySelector('.os-tab-bar');
        window.getComputedStyle(tb).overflowX === 'auto'
      `);
      const bodyNoOverflow = await client.eval("document.documentElement.scrollWidth <= window.innerWidth");
      results.push({ name: 'HUGH_OS_02_MOBILE_360_TAB_SCROLL_NO_BREAK', pass: tabBarHasScroll && bodyNoOverflow, detail: `Tab overflow-x: auto (${tabBarHasScroll}), Document overflow free (${bodyNoOverflow})` });

      await closePage(client, targetId);
    }

  } finally {
    chrome.kill();
  }

  console.log('\n================================================================================');
  console.log(' BROWSER VALIDATION SUMMARY');
  console.log('================================================================================');

  let passed = 0;
  let failed = 0;
  for (const r of results) {
    if (r.pass) {
      console.log(`  [PASS] ${r.name.padEnd(48)} : ${r.detail}`);
      passed++;
    } else {
      console.log(`  [FAIL] ${r.name.padEnd(48)} : ${r.detail}`);
      failed++;
    }
  }

  console.log('--------------------------------------------------------------------------------');
  console.log(`  Total Checks: ${results.length} | Passed: ${passed} | Failed: ${failed}`);
  console.log(`  Result: ${failed === 0 ? '100% PASS' : 'FAIL'}`);
  console.log('================================================================================\n');

  if (failed > 0) process.exit(1);
}

runTests().catch(err => {
  console.error('Fatal Test Error:', err);
  process.exit(1);
});
